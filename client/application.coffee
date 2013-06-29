window.MABL = {
  init: ->

  start: ->
    console.log "starting app"

}

window.MABL.init()

Meteor.startup( () ->
  window.MABL.start();
)