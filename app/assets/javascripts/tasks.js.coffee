$ ->

  CHECK_INTERVAL = 5000

  $('.task-page #submit_button').on 'click', ->
    if $('#source').val().length == 0
      $.gritter.add {image: '/assets/warning.png', title: 'Empty solution', text: 'Your can\'t submit empty solution.'}
      return
    $('#submit_form').submit()
    $('#source').val('')

  updateSubmissionsByResponse = (submissions) ->
    $(submissions).each (ind, submission) ->
      result = submission.result
      return if result == 'testing'
      div = $('#' + submission.id)
      div.removeAttr('data-testing')
      image = '/assets/' + result + '.png'
      div.find('.result img').attr('src', image)
      title = result.substr(0, 1).toUpperCase() + result.substr(1)
      message = if result == 'accepted' then 'Solution has been accepted.' else 'Solution has failed.'
      $.gritter.add {image: image, title: title, text: message}

  checkSubmissions = ->
    ids = $('.submission[data-testing="true"]').map( -> this.id ).toArray()
    if ids.length == 0
      window.setTimeout checkSubmissions, CHECK_INTERVAL
    else
      $.ajax {
        url: '/check_submissions',
        data: {ids: ids},
        success: (data) ->
          updateSubmissionsByResponse data
        complete: ->
          window.setTimeout checkSubmissions, CHECK_INTERVAL
      }


  window.setTimeout checkSubmissions, CHECK_INTERVAL


  $('.task-page #submit_form').on 'ajax:success', (evt, data) ->
    current_page = $('.task-page #pagination .current').text().trim()
    # Refresh div with submissions.
    $.ajax {
      url: window.location.href,
      data: {page: current_page},
      beforeSend: (xhr, settings) ->
        xhr.setRequestHeader('accept', '*/*;q=0.5, ' + settings.accepts.script)
    }
