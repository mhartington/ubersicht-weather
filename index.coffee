apiKey: '11fd2a857e75221af61a3a2267e64a5b' # put your forcast.io api key inside the quotes here

refreshFrequency: 60000

style: """
  bottom: 30px
  left: 125px
  margin: 0 0 0 -100px
  font-family: "HelveticaNeue-Light"
  font-weight: 100
  color: #fff

  @font-face
    font-family Weather
    src url(weather.widget/icons.svg) format('svg')

  .icon
    font-family: Weather
    font-size: 40px
    padding-bottom 10px

  .temp
    font-size: 20px
    padding-bottom 10px

  .location
    padding-bottom 10px


  .summary
    font-size: 14px
    padding-bottom 10px

"""

command: "echo {}"

render: (o) -> """
  <div class="icon"></div>
  <div class="temp"></div>
  <div class="location"></div>
  <div class='summary'></div>
"""

afterRender: (domEl) ->
  geolocation.getCurrentPosition (e) =>
    coords     = e.position.coords
    [lat, lon] = [coords.latitude, coords.longitude]
    @command   = @makeCommand(@apiKey, "#{lat},#{lon}")

    $(domEl).find('.location').prop('textContent', e.address.city)
    @refresh()


makeCommand: (apiKey, location) ->
  exclude  = "minutely,hourly,alerts,flags"
  "curl -sS 'https://api.forecast.io/forecast/#{apiKey}/#{location}?units=auto&exclude=#{exclude}'"

update: (output, domEl) ->
  data  = JSON.parse(output)
  today = data.daily?.data[0]

  return unless today?
  date  = @getDate today.time

  $(domEl).find('.temp').html  Math.round(today.temperatureMax)+'°'
  $(domEl).find('.summary').html today.summary
  $(domEl).find('.icon').html @getIcon(today)

dayMapping:
  0: 'Sunday'
  1: 'Monday'
  2: 'Tuesday'
  3: 'Wednesday'
  4: 'Thursday'
  5: 'Friday'
  6: 'Saturday'

iconMapping:
  "rain"                :"\uf019"
  "snow"                :"\uf01b"
  "fog"                 :"\uf014"
  "cloudy"              :"\uf013"
  "wind"                :"\uf021"
  "clear-day"           :"\uf00d"
  "mostly-clear-day"    :"\uf00c"
  "partly-cloudy-day"   :"\uf002"
  "clear-night"         :"\uf02e"
  "partly-cloudy-night" :"\uf031"
  "unknown"             :"\uf03e"

getIcon: (data) ->
  return @iconMapping['unknown'] unless data
  if data.icon.indexOf('cloudy') > -1
    if data.cloudCover < 0.25
      @iconMapping["clear-day"]
    else if data.cloudCover < 0.5
      @iconMapping["mostly-clear-day"]
    else if data.cloudCover < 0.75
      @iconMapping["partly-cloudy-day"]
    else
      @iconMapping["cloudy"]
  else
    @iconMapping[data.icon]

getDate: (utcTime) ->
  date  = new Date(0)
  date.setUTCSeconds(utcTime)
  date
