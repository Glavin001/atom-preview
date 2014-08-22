class Greet extends Service
  constructor: ($log) ->
    @sayHello = (name) ->
      $log.info "Hello #{name}!"

class Home extends Controller
  constructor: (greetService) ->
    greetService.sayHello 'Luke Skywalker'
