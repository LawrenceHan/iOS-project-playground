$ ->
  locale = $('#main').data('locale')
  short_locale = locale.split('-')[0]

  if short_locale == 'zh'
    $.datepicker.setDefaults($.datepicker.regional['zh-CN'])
  else
    $.datepicker.setDefaults($.datepicker.regional[''])

  $('.datepicker:first').datepicker
    changeMonth: true,
    changeYear: true,
    dateFormat: 'yy-mm-dd'
    defaultDate: '1980-01-01',
    yearRange: '1900:2000'

  $('.datepicker').datepicker
    changeMonth: true,
    changeYear: true,
    dateFormat: 'yy-mm-dd'

  required_text = if short_locale == 'zh' then "必须填写" else "Answer required"
  $.extend $.validator.messages,
    required: required_text

  $('form').validate()

  redirectCount = ->
    count = $('#redirectCount')
    if count.length > 0
      reduceRedirectCount = ->
        current = parseInt count.text()
        if current == 0
          return window.location = 'http://www.thecarevoice.com'
        count.text(current - 1)
      count.text(5)
      setInterval(reduceRedirectCount, 1000)

  redirectCount()

  hospitals = $('.hospital-select').data('hospitals')
  if hospitals
    hospitals.map (hospital) ->
      $('.hospital-select').append($('<option/>').val(hospital.id).text(hospital.name))
    $('.hospital-select').select2()
    $('.hospitals-loading-img').addClass('hide')
  else
    $.getJSON '/v2/hospitals?' + $.param(locale: locale), (data) ->
      data.map (hospital) ->
        $('.hospital-select').append($('<option/>').val(hospital.id).text(hospital.name))
      $('.hospital-select').select2()
      $('.hospitals-loading-img').addClass('hide')

  physician_ids = $('.physician-select').data('physician-ids')
  $('.hospital-select').change ->
    hospital_id = $(this).val()
    if hospital_id
      $('.physicians-loading-img').removeClass('hide')
      $.getJSON "/v2/hospitals/#{hospital_id}/physicians?" + $.param(locale: locale, physician_ids: physician_ids), (data) ->
        $('.physician-select').select2('destroy')
        select_text = $('.physician-select option:first').text()
        $('.physician-select').html('')
        $('.physician-select').append($('<option/>').text(select_text))
        data.map (physician) ->
          text = if physician.department_name then physician.name+' / '+physician.department_name else physician.name
          $('.physician-select').append($('<option/>').val(physician.id).text(text))
        $('.physician-select').select2()
        $('.physicians-loading-img').addClass('hide')

  $('.select-with-other').change ->
    value = $(this).val()
    if value.indexOf('Other') == 0 || value.indexOf('其它') == 0
      $(this).siblings('input[type=text]').removeClass('hide').attr('required', 'required')
    else
      $(this).siblings('input[type=text]').addClass('hide').removeAttr('required')
