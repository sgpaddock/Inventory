Router.configure
  layoutTemplate: 'layout'
  loadingTemplate: 'loading'
  onBeforeAction: ->
    if Meteor.isClient and not Meteor.userId()
      @render 'login'
    else
      @next()

Router.map ->
  @route 'default',
    path: '/'
    waitOn: -> Meteor.subscribe 'userData'

  @route 'userDashboard',
    path: '/my/dashboard'
    onBeforeAction: ->
      Session.set 'queueName', null
      Session.set 'pseudoQueue', null
      @next()

  @route 'apiSubmit',
    path: '/api/1.0/submit'
    where: 'server'
    action: ->
      # TODO: check X-Auth-Token header
      unless @request.headers['x-forwarded-for'] in Meteor.settings?.remoteWhitelist
        console.log 'API submit request from '+@request.headers['x-forwarded-for']+' not in API whitelist'
        throw new Meteor.Error 403,
          'Access denied.  Submit from a whitelisted IP address or use an API token.'

      console.log @request.body
      requiredParams = ['username', 'email', 'description', 'queueName']
      for k in requiredParams
        if not @request.body[k]? then throw new Meteor.Error 412, "Missing required parameter #{k} in request."

      Meteor.call 'checkUsername', @request.body.username

      blackboxKeys = _.difference(_.keys(@request.body), requiredParams.concat(['submitter_name', 'subject_line'], Tickets.simpleSchema()._schemaKeys))
      formFields = _.pick(@request.body, blackboxKeys)

      Tickets.insert
        title: @request.body.subject_line
        body: @request.body.description
        authorName: @request.body.username
        authorId: Meteor.users.findOne({username: @request.body.username})._id
        submissionData:
          method: 'Form'
          ipAddress: @request.body.ip_address
          hostname: @request.body.hostname? @request.body.ip_address
        submittedTimestamp: Date.now()
        queueName: @request.body.queueName || 'Triage'
        tags: @request.body.tags?.split(';\n') || []
        formFields: formFields
        attachmentIds: _.pluck(@request.files, '_id')

      @response.end 'Submission successful.'

  @route 'serveFile',
    path: '/file/:filename'
    where: 'server'
    action: FileRegistry.serveFile

