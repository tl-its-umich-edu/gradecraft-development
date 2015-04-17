@gradecraft.controller 'RubricCtrl', ['$scope', 'Restangular', 'MetricPrototype', 'CourseBadgePrototype', '$http', ($scope, Restangular, MetricPrototype, CourseBadgePrototype, $http) -> 
 # hide modal window by default
  $scope.modalShown = false
  $scope.toggleModal = ->
    $scope.modalShown = not $scope.modalShown
    return

  INTEGER_REGEXP = /^\-?\d+$/
  Restangular.setRequestSuffix('.json')
  $scope.metrics = []
  $scope.courseBadges = {}
  $scope.savedMetricCount = 0

  $scope.init = (rubricId, pointTotal, metrics, courseBadges)->
    $scope.rubricId = rubricId
    $scope.pointTotal = parseInt(pointTotal)
    $scope.addCourseBadges(courseBadges)
    $scope.addMetrics(metrics)

  # distill key/value pairs for metric ids and relative order
  $scope.pointsAssigned = ()->
    points = 0
    angular.forEach($scope.metrics, (metric, index)->
      points += metric.max_points if metric.max_points
    )
    points or 0

  $scope.pointsDifference = ()->
    $scope.pointTotal - $scope.pointsAssigned()
 
  $scope.pointsRemaining = ()->
    pointsRemaining = $scope.pointsDifference()
    if pointsRemaining > 0 then pointsRemaining else 0

  # Methods for identifying point deficit/overage
  $scope.pointsMissing = ()->
    $scope.pointsDifference() > 0 and $scope.pointsAssigned() > 0

  # check whether points overview is hidden
  # $scope.pointsOverviewHidden = ()->
  #  element = angular.element(document.querySelector('#points-overview'))
  #  element.is('visible')

  $scope.pointsSatisfied = ()->
    $scope.pointsDifference() == 0 and $scope.pointsAssigned() > 0

  $scope.pointsOverage = ()->
    $scope.pointsDifference() < 0

  $scope.showMetric = (attrs)->
    new MetricPrototype(attrs, $scope)

  $scope.countSavedMetric = () ->
    $scope.savedMetricCount += 1

  $scope.addCourseBadges = (courseBadges)->
    angular.forEach(courseBadges, (badge, index)->
      courseBadge = new CourseBadgePrototype(badge)
      $scope.courseBadges[badge.id] = courseBadge
    ) 

  $scope.addMetrics = (existingMetrics)->
    angular.forEach(existingMetrics, (em, index)->
      emProto = new MetricPrototype(em, $scope)
      $scope.countSavedMetric() # indicate saved metric present
      $scope.metrics.push emProto
    )

  $scope.newMetric = ()->
    m = new MetricPrototype(null, $scope)
    $scope.metrics.push m

  $scope.getNewMetric = ()->
    $scope.newerMetric = Restangular.one('metrics', 'new.json').getList().then ()->

  $scope.viewMetrics = ()->
    if $scope.metrics.length > 0
      $scope.displayMetrics = []
      angular.forEach($scope.metrics, (value, key)->
        $scope.displayMetrics.push(value.name)
      )
      $scope.displayMetrics

  $scope.existingMetrics = []

  # declare a sortableEle variable for the sortable function
  sortableEle = undefined

  # action when a sortable drag begins
  $scope.dragStart = (e, ui) ->
    ui.item.data "start", ui.item.index()
    return

  # action when a sortable drag completes
  $scope.dragEnd = (e, ui) ->
    start = ui.item.data("start")
    end = ui.item.index()
    $scope.metrics.splice end, 0, $scope.metrics.splice(start, 1)[0]
    $scope.$apply()
    $scope.updateMetricOrder()
    return

  # send the metric order to the server with ids
  $scope.updateMetricOrder = ()->
    if $scope.savedMetricCount > 0
      $http.put("/metrics/update_order", metric_order: $scope.orderedMetrics()).success(
      )
      .error(
      )

  # distill key/value pairs for metric ids and relative order
  $scope.orderedMetrics = ()->
    metrics = {}
    angular.forEach($scope.metrics, (value, index)->
      metrics[value.id] = {order: index} if value.id != null
    )
    metrics

  sortableEle = $("#metric-box").sortable(
    start: $scope.dragStart
    update: $scope.dragEnd
  )
  return
]