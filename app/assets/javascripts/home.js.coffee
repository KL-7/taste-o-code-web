@Styx.Initializers.Home =
  show: -> $ ->
    $('.language').on 'click', (event) ->
      return if $(event.target).hasClass 'buy'
      url = '/languages/' + this.id;
      window.location = url

    showDialog = (dialog) ->
      dialog_top = $(window).height() / 2 + dialog.height()
      dialog.css {top: dialog_top}
      dialog.reveal {animation: 'fade', closeOnBackgroundClick: false}


    $('#non_purchased_langs .buy').on 'click', ->
      lang = $(this).parent('.language')
      $('#lang_name').html lang.find('.name').html()
      $('#lang_price').html lang.find('.price').html()
      $('#buy_form #lang_id').val lang.attr('id')
      showDialog $('#buy_dialog')

    $('#buy_button').on 'click', ->
      $(this).trigger 'reveal:close'
      $('#buy_form').submit()

    $('#cancel_button').on 'click', ->
      $(this).trigger 'reveal:close'

    moveLanguage = (lang, tasksCount) ->
      duration = 1000
      lang.fadeOut duration, ->
        $('#purchased_langs').prepend lang
        lang.find(el).remove() for el in ['.price', '.buy']
        scores = $('<div/>')
          .addClass('score middle')
          .append($('<p/>').addClass('solved').text('0'))
          .append($('<p/>').addClass('unsolved').text('/ ' + tasksCount))
        progress = $('<div/>')
          .addClass('progress')
          .append($('<p/>').addClass('solved').css('width', '0%'))
        lang.append(scores).append progress
        lang.fadeIn duration

    removeBuyButtons = (availablePoints) ->
      $('#non_purchased_langs .language')
        .filter( -> $(this).attr('data-price') > availablePoints )
        .find('.buy').remove()

    $('#buy_form').on 'ajax:success', (evt, data) ->
      if data.success
        lang = $('#' + data.lang)
        $('#points').text data.available_points
        moveLanguage lang, data.tasks_count
        removeBuyButtons data.available_points
      else
        window.alert """You can't buy this language.\n
                      May be we can't connect to server :|\n
                      or you're out of points :(\n
                      or you've already bought this language o_O\n
                      or you're trying to break the system! >:O"""

  greeting: (data) -> $ ->
    $(data.langs).each (ind, lang) ->
      div = $('#' + lang.name).children('.code')[0];
      CodeMirror(
        div,
        {
          mode: lang.syntax_mode || 'text/plain',
          theme: 'default',
          readOnly: true,
          lineWrapping: true,
          value: lang.code
        }
      )

