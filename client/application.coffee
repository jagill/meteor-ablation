window.MABL = {
  start: ->
    console.log "starting app"

}

Meteor.startup( () ->
  window.MABL.start();
)