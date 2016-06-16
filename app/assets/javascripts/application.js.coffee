# This is a manifest file that'll be compiled into application js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https:#github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery_ujs
#= require bootstrap
#= require js.cookie
#= require bootstrap-hover-dropdown
#= require bootstrap-switch
#= require jquery.backstretch
#= require jquery.blockui
#= require jquery.slimscroll
#= require jquery.validate
#= require metronic_app
#= require metronic_dashboard_layout
#= require datatable
#= require datatables.min
#= require datatables.bootstrap
#= require table-datatables-colreorder
#= require bootstrap-fileinput
#= require dropify
#= require components-date-time-pickers.min
#= require bootstrap-datepicker.min
#= require bootstrap-confirmation.min
#= require toastr

$(document).on('ready page:load', () ->
  $('.dropify').dropify({
    tpl: {
      wrap:            '<div class="dropify-wrapper"></div>',
      loader:          '<div class="dropify-loader"></div>',
      message:         '<div class="dropify-message"><span class="file-icon" /> <p>{{ default }}</p></div>',
      preview:         '<div class="dropify-preview"><span class="dropify-render"></span><div class="dropify-infos"><div class="dropify-infos-inner"><p class="dropify-infos-message">{{ replace }}</p></div></div></div>',
      filename:        '<p class="dropify-filename"><span class="file-icon"></span> <span class="dropify-filename-inner"></span></p>',
      clearButton:     '<button type="button" class="dropify-clear">{{ remove }}</button>',
      errorLine:       '<p class="dropify-error">{{ error }}</p>',
      errorsContainer: '<div class="dropify-errors-container"><ul></ul></div>'
    }

    error: {
      'fileSize': 'The file size is too big ({{ value }} max).',
      'minWidth': 'The image width is too small ({{ value }}}px min).',
      'maxWidth': 'The image width is too big ({{ value }}}px max).',
      'minHeight': 'The image height is too small ({{ value }}}px min).',
      'maxHeight': 'The image height is too big ({{ value }}px max).',
      'imageFormat': 'The image format is not allowed ({{ value }} only).'
    }

    messages: {
      'default': 'Drag and drop a file here or click',
      'replace': 'Drag and drop or click to replace',
      'remove':  'Remove',
      'error':   'Ooops, something wrong appended.'
    }
  })

  $('#js-excel-xml').bind('change', () ->
    $(this).closest('form').submit()
  )

  if notice
    notice_json = JSON.parse(notice)
    message = null
    type = null
    if notice_json.success
      message = notice_json.success
      type = 'success'
    else if notice_json.error
      message = notice_json.error
      type = 'error'
    else if notice_json.info
      message = notice_json.info
      type = 'info'
    else if notice_json.warning
      message = notice_json.warning
      type = 'warning'
    if message && type
      toastr[type] message, notice_json.title
)

$(document).ready ->
  $('#confirm-delete').on 'show.bs.modal', (e) ->
    $(this).find('#form-delete').attr 'action', $(e.relatedTarget).data('href')
