fields = [ 'offCampusStreetAddress', 'offCampusJustification' ]

Template.offCampusRecordModal.helpers
  asset: ->
    return Inventory.findOne {propertyTag: Session.get('propertyTag')}
  success: -> Template.instance().success.get()
  error: -> Template.instance().error.get()
  warning: -> Template.instance().warning.get()

Template.offCampusRecordModal.events
  'show.bs.modal': (e, tpl) ->
    zIndex = 1040 + ( 10 * $('.modal:visible').length)
    $(e.target).css('z-index', zIndex)
    setTimeout ->
      $('.modal-backdrop').not('.modal-stack').css('z-index',  zIndex-1).addClass('modal-stack')
    , 10

  'hidden.bs.modal': (e, tpl) ->
    Blaze.remove tpl.view
    if $('.modal:visible').length
      $(document.body).addClass('modal-open')

  'click button[data-action=submit]': (e, tpl) ->
    offCampusRecord = {}
    _.each fields, (f) ->
      unless tpl.$("[data-schema-key=#{f}]").is(':disabled')
        $el = tpl.$("[data-schema-key=#{f}]")
        if $el.data('required')
          if !$el.val().length
            $el.closest('.form-group').addClass('has-error')
          else
            $el.closest('.form-group').removeClass('has-error')
        offCampusRecord[f] = tpl.$("[data-schema-key=#{f}]").val()
        console.log (offCampusRecord[f])
    offCampusRecord['offCampusCertification'] = tpl.$('[data-schema-key=offCampusCertification]').is(':checked')
    Meteor.call 'updateOffCampusInformation', tpl.docId, offCampusRecord, (err, success) ->
      if (err)
        console.log(err)
        Inventory.simpleSchema().namedContext('assetForm').addInvalidKeys err.invalidKeys
      else
        $('#offCampusRecordModal').modal('hide')


Template.offCampusRecordModal.created = ->
  @docId = Inventory.findOne()?._id

#Template.offCampusRecordModal.onCreated ->
 # @error = new ReactiveVar()
  #@success = new ReactiveVar(false)
  #@warning = new ReactiveVar()
