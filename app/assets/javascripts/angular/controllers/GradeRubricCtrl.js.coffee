@gradecraft.controller 'GradeRubricCtrl', ['$scope', 'Restangular', 'MetricPrototype', 'CourseBadgePrototype', 'RubricGradePrototype', '$http', ($scope, Restangular, MetricPrototype, CourseBadgePrototype, RubricGradePrototype, $http) -> 

  $scope.metrics = []
  $scope.courseBadges = {}
  $scope.rubricGrades = {} # index in hash with metric_id as key
  $scope.gsiGradeStatuses = ["In Progress", "Graded"]
  $scope.professorGradeStatuses = ["In Progress", "Graded", "Released"]

  $scope.pointsPossible = 0
  $scope.pointsGiven = 0

  $scope.init = (rubricId, metrics, assignmentId, studentId, rubricGrades, gradeStatus, courseBadges, releaseNecessary)->
    $scope.rubricId = rubricId
    $scope.assignmentId = assignmentId
    $scope.studentId = studentId
    if gradeStatus
      $scope.gradeStatus = gradeStatus
    else
      $scope.gradeStatus = ""

    # use 'Graded' for all assignments for which release is necessary, bypass ui
    $scope.releaseNecessary = releaseNecessary
    if not $scope.releaseNecessary
      $scope.gradeStatus = "Graded"

    $scope.addRubricGrades(rubricGrades)
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
    $scope.pointsPossible - $scope.pointsGiven()

  $scope.pointsRemaining = ()->
    pointsRemaining = $scope.pointsDifference()
    if pointsRemaining > 0 then pointsRemaining else 0

  # Methods for identifying point deficit/overage
  $scope.pointsMissing = ()->
    $scope.pointsDifference() > 0 and $scope.pointsGiven() > 0

  $scope.pointsSatisfied = ()->
    $scope.pointsDifference() == 0 and $scope.pointsGiven() > 0

  $scope.pointsOverage = ()->
    $scope.pointsDifference() < 0

  $scope.showMetric = (attrs)->
    new MetricPrototype(attrs, $scope)

  # count how many tiers have been selected in the UI
  $scope.tiersSelected = []
  $scope.selectedTiers = ()->
    tiers = []
    angular.forEach($scope.metrics, (metric, index)->
      if metric.selectedTier
        tiers.push metric.selectedTier
    )
    $scope.tiersSelected = tiers
    tiers


  $scope.selectedTierIds = []
  # count how many tiers have been selected in the UI
  $scope.selectedTierIds = ()->
    tierIds = []
    angular.forEach($scope.metrics, (metric, index)->
      if metric.selectedTier
        tierIds.push metric.selectedTier.id
    )
    $scope.selectedTierIds = tierIds
    tierIds

  $scope.allMetricIds = []
  # ids of all the metrics in the rubric
  $scope.allMetricIds = ()->
    metricIds = []
    angular.forEach($scope.metrics, (metric, index)->
      metricIds.push metric.id
    )
    $scope.allMetricIds = metricIds
    metricIds

  # count how many points have been given from those tiers
  $scope.pointsGiven = ()->
    points = 0
    angular.forEach($scope.metrics, (metric, index)->
      if metric.selectedTier
        points += metric.selectedTier.points
    )
    points 

  $scope.gradedMetrics = ()->
    metrics = []
    angular.forEach($scope.metrics, (metric, index)->
      if metric.selectedTier
        metrics.push metric
    )
    metrics 

  $scope.selectedMetrics = ()->
    metrics = []
    angular.forEach($scope.metrics, (metric, index)->
      if metric.selectedTier
        metrics.push metric
    )
    $scope.selectedMetrics = metrics
    metrics 

  $scope.gradedMetricsParams = ()->
    params = []
    angular.forEach($scope.gradedMetrics(), (metric, index)->
      # get params just from the metric object
      metricParams = $scope.metricOnlyParams(metric,index)

      # add params from the tier if a tier has been selected
      if metric.selectedTier
        jQuery.extend(metricParams, $scope.gradedTierParams(metric))

      # create params for the rubric grade regardless
      params.push metricParams
    )
    params

  # params for just the metric
  $scope.metricOnlyParams = (metric,index)->
    {
      metric_name: metric.name,
      metric_description: metric.description,
      max_points: metric.max_points,
      order: index,
      metric_id: metric.id,
      comments: metric.comments
    }

  # additional tier params if a tier is selected
  $scope.gradedTierParams = (metric) ->
    {
      tier_name: metric.selectedTier.name,
      tier_description: metric.selectedTier.description,
      points: metric.selectedTier.points,
      tier_id: metric.selectedTier.id
    }

  $scope.tierBadgesParams = ()->
    params = []
    # alert("# of graded metrics:" + $scope.gradedMetrics.length)
    angular.forEach($scope.gradedMetrics(), (metric, index)->
      # alert(metric.name)
      # grab the selected tier for the active metric
      tier = metric.selectedTier
      angular.forEach(tier.badges, (badge, index)->
        params.push {
          name: badge.name,
          tier_id: tier.id,
          metric_id: tier.metric_id,
          badge_id: badge.badge.id,
          description: badge.description,
          point_total: badge.point_total,
          icon: badge.icon,
          multiple: badge.multiple
        }
      )
    )
    return params

  $scope.gradedRubricParams = ()->
    {
      points_given: $scope.pointsGiven(),
      rubric_id: $scope.rubricId,
      student_id: $scope.studentId,
      points_possible: $scope.pointsPossible,
      rubric_grades: $scope.gradedMetricsParams(),
      tier_badges: $scope.tierBadgesParams(),
      tier_ids: $scope.selectedTierIds(),
      metric_ids: $scope.allMetricIds(),
      grade_status: $scope.gradeStatus
    }

  $scope.submitGrade = ()->
    self = this
    if confirm "Are you sure you want to submit the grade for this assignment?"
      # alert(self.gradedRubricParams().tier_badges.length)
      $http.put("/assignments/#{$scope.assignmentId}/grade/submit_rubric", self.gradedRubricParams()).success(
        window.location = "/assignments/#{$scope.assignmentId}"
      )
      .error(
      )

  $scope.addRubricGrades = (rubricGrades)->
    angular.forEach(rubricGrades, (rg, index)->
      rubricGrade = new RubricGradePrototype(rg)
      $scope.rubricGrades[rg.metric_id] = rubricGrade
    )

  $scope.addCourseBadges = (courseBadges)->
    angular.forEach(courseBadges, (badge, index)->
      courseBadge = new CourseBadgePrototype(badge)
      $scope.courseBadges[badge.id] = courseBadge
    )

  $scope.addMetrics = (existingMetrics)->
    angular.forEach(existingMetrics, (metric, index)->
      metricObject = new MetricPrototype(metric, $scope)
      $scope.metrics.push metricObject
      $scope.pointsPossible += metricObject.max_points
    )

  $scope.existingMetrics = []
]