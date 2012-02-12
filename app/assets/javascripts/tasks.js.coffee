@Styx.Initializers.Tasks =

  show: (data) ->
    $ ->
      CHECK_INTERVAL = 3000

      CODE_MIRROR_THEMES = ['default', 'cobalt', 'eclipse', 'elegant', 'monokai', 'neat', 'night', 'rubyblue']

      CODE_MIRROR_THEME_COOKIE = 'cm-theme'

      storeTheme = (theme) -> $.cookie CODE_MIRROR_THEME_COOKIE, theme, { path: '/', expires: 30 }

      themeSelector = $('.cm-theme-selector select')
      themeSelector.append $('<option>').val(theme).text(theme) for theme in CODE_MIRROR_THEMES

      theme = $.cookie(CODE_MIRROR_THEME_COOKIE) ? 'default'

      storeTheme theme
      themeSelector.val theme

      window.sourceEditor = CodeMirror.fromTextArea(
        document.getElementById('source'),
        {
          mode: data.syntax_mode || 'text/plain',
          theme: theme,
          lineNumbers: true
        }
      )

      themeSelector.change ->
        theme = $(this).val()
        storeTheme theme
        window.sourceEditor.setOption 'theme', theme

      $('#source_container').css visibility: 'visible'

      $('#submit_button').on 'click', ->
        window.sourceEditor.save()
        if $('#source').val().length > 0
          $('#submit_form').submit()
        else
          $.gritter.add {image: '/assets/warning.png', title: 'Empty solution', text: 'Your can\'t submit empty solution.'}

      setCheckSubmissionsTimer = -> window.setTimeout checkSubmissions, CHECK_INTERVAL

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
          $.gritter.add { image: image, title: title, text: message }

      checkSubmissions = ->
        ids = $('.submission[data-testing="true"]').map(-> this.id).toArray()
        if ids.length > 0
          $.ajax {
            url: '/check_submissions',
            data: { ids: ids },
            success: (data) -> updateSubmissionsByResponse(data)
            complete: setCheckSubmissionsTimer
          }
        else
          setCheckSubmissionsTimer()

      setCheckSubmissionsTimer()

      $('#submit_form').on 'ajax:success', (evt, data) ->
        current_page = $('#pagination .current').text().trim()
        # Refresh div with submissions.
        $.ajax {
          url: window.location.href,
          data: { page: current_page },
          beforeSend: (xhr, settings) -> xhr.setRequestHeader('accept', '*/*;q=0.5, ' + settings.accepts.script)
        }
