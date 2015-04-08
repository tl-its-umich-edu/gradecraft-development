@gradecraft.factory 'MetricPrototype', ['$http', 'Restangular', 'TierPrototype', 'MetricBadgePrototype', ($http, Restangular, TierPrototype, MetricBadgePrototype) ->
  class MetricPrototype
    constructor: (attrs={}, $scope)->
      @$scope = $scope
      @tiers = []
      @badges = {}
      @id = if attrs.id then attrs.id else null
      @fullCreditTier = null
      @name = if attrs.name then attrs.name else ""
      @rubricId = if attrs.rubric_id then attrs.rubric_id else @$scope.rubricId
      if @id
        @max_points = if attrs.max_points then attrs.max_points else 0
      else
        @max_points = if attrs.max_points then attrs.max_points else null

      @description = if attrs.description then attrs.description else ""
      @hasChanges = false

      ## graderubric
      @selectedTier = null
      
      # look for a rubric grade by metric_id if there are rubric grades present
      if @$scope.rubricGrades
        @rubricGrade = @$scope.rubricGrades[@id]

      # if there are rubric grades, select the 
      if @rubricGrade
        @rubricGradeTierId = @rubricGrade.tier_id
      else
        @rubricGradeTierId = null

      if @rubricGrade
        @comments = @rubricGrade.comments
      else
        @comments = ""

      @addTiers(attrs["tiers"]) if attrs["tiers"] #add tiers if passed on init
      # would this always have an id?
    alert: ()->
      alert("snakes!")    
    addTier: (attrs={})->
      newTier = new TierPrototype(@, attrs, @$scope)
      @tiers.push newTier
      if @rubricGradeTierId and @rubricGradeTierId == newTier.id
        @selectedTier = newTier

    addTiers: (tiers)->
      angular.forEach(tiers, (tier,index)=>
        @addTier(tier)
      )
    resourceUrl: ()->
      "/metrics/#{@id}"
    order: ()->
      jQuery.inArray(this, @$scope.metrics)

    loadMetricBadge: (metricBadge)->
      courseBadge = @availableBadges[metricBadge.badge_id]
      loadedBadge = new MetricBadgePrototype(@, angular.copy(courseBadge))
      @badges[courseBadge.id] = loadedBadge # add metric badge to metric
      delete @availableBadges[courseBadge.id] # remove badge from available badges on metric

    # Badges
    loadMetricBadges: (metricBadges)->
      angular.forEach(metricBadges, (metricBadge, index)=>
        if (@availableBadges[metricBadge.badge_id])
          @loadMetricBadge(metricBadge)
      )

    index: ()->
      @order()
    createRubricGrade: ()->
      $http.post("/rubric_grades.json", @rubricGradeParams()).success().error()
    gradeWithTier: (tier)->
      if @isUsingTier(tier)
        @selectedTier = null
      else
        @selectedTier = tier
    isUsingTier: (tier)->
      @selectedTier == tier
    rubricGradeParams: ()->
      {
        metric_name: @name,
        metric_description: @description,
        max_points: @max_points,
        order: @order,
        tier_name: @selectedTier.name,
        tier_description: @selectedTier.description,
        points: @selectedTier.points,
        submission_id: submission_id,
        metric_id: @id,
        tier_id: @selectedTier.id,
        comments: @comments
      }
    selectBadge: ()->
      newBadge = new MetricBadgePrototype(@, angular.copy(@selectedBadge))
      @badges[newBadge.badge.id] = newBadge # add metric badge to metric
      delete @availableBadges[@selectedBadge.id] # remove badge from available badges on metric
      @selectedBadge = "" # reset selected badge

    deleteMetricBadge: (metricBadge)->
      if confirm("Are you sure you want to delete this badge from the metric?")
        $http.delete("/metric_badges/#{metricBadge.id}").success(
          (data,status)=>
            @availableBadges[metricBadge.badge.id] = angular.copy(@$scope.courseBadges[metricBadge.badge.id])
            delete @badges[metricBadge.badge.id]
        ).error((err)->
          alert("delete failed!")
        )

    badgeIds: ()->
      # distill ids for all badges
      badgeIds = []
      angular.forEach(@badges, (badge, index)->
        badgeIds.push(badge.id)
      )
      badgeIds

    isNew: ()->
      @id is null
    isSaved: ()->
      @id != null
    change: ()->
      if @fullCreditTier
        @updateFullCreditTier()
      if @isSaved()
        @hasChanges = true
    updateFullCreditTier: ()->
      @tiers[0].points = @max_points
    resetChanges: ()->
      @hasChanges = false
    params: ()->
      {
        name: @name,
        max_points: @max_points,
        order: @order(),
        description: @description,
        rubric_id: @rubricId
      }
    destroy: ()->

    remove:(index)->
      @$scope.metrics.splice(index,1)
    create: ()->
      Restangular.all('metrics').post(@params())
        .then (response)=>
          metric = response.existing_metric
          @id = metric.id
          @$scope.countSavedMetric()
          @addTiers(metric.tiers)

    modify: (form)->
      if form.$valid
        if @isNew()
          @create()
        else
          @update()

    update: ()->
      if @hasChanges
        Restangular.one('metrics', @id).customPUT(@params())
          .then(
            ()-> , #success
            ()-> # failure
          )
        @resetChanges()

    delete: (index)->
      if @isSaved()
        if confirm("Are you sure you want to delete this metric? Deleting this metric will delete its tiers as well.")
          $http.delete("/metrics/#{@id}").success(
            (data,status)=>
              @remove(index)
          )
          .error((err)->
            alert("delete failed!")
          )
      else
        @remove(index)            
]  
