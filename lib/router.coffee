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
    template: 'inventory'
    waitOn: ->
      Meteor.subscribe 'userData'
    onBeforeAction: ->
      Session.set 'itemSet', []
      filter = Filter.getFilterFromQuery @params.query
      Meteor.subscribe 'inventory', filter, onReady: ->
        Session.set 'ready', true
      Meteor.subscribe 'newInventory', filter, new Date()
      @next()

  @route 'import',
    path: '/import'
    template: 'import'

  @route 'userDashboard',
    path: '/my/dashboard'

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

      ###
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
        ###

      @response.end 'Submission successful.'

  @route 'serveFile',
    path: '/file/:filename'
    where: 'server'
    action: FileRegistry.serveFile

