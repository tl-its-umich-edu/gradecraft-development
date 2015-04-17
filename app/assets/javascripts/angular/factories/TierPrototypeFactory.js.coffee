@gradecraft.factory 'TierPrototype', ['$http', 'Restangular', 'TierBadgePrototype', ($http, Restangular, TierBadgePrototype) ->
  class TierPrototype
    constructor: (metric, attrs={}, $scope)->
      @$scope = $scope
      @id = attrs.id or null
      @metric = metric
      @badges = {}
      @availableBadges = angular.copy($scope.courseBadges)
      @selectedBadge = ""
      @id = if attrs.id then attrs.id else null

      @loadTierBadges(attrs["tier_badges"]) if attrs["tier_badges"] #add badges if passed on init
      @metric_id = metric.id
      @name = attrs.name or ""
      @editingBadges = false
      @points = attrs.points || 0
      @fullCredit = attrs.full_credit or false
      @noCredit = attrs.no_credit or false
      @durable = attrs.durable or false
      @description = attrs.description or ""
      @resetChanges()

    isNew: ()->
      @id is null
    isSaved: ()->
      @id > 0
    change: ()->
      if @isSaved()
        @hasChanges = true
    alert: ()->
      alert("snakes!")        
    resetChanges: ()->
      @hasChanges = false
    params: ()->
      metric_id: @metric_id,
      name: @name,
      points: @points,
      description: @description
    metricName: ()->
      alert @metric.name
    removeFromMetric: (index)->
      @metric.tiers.splice(index,1)
    
    ##grade rubric ctrl
    # loadTierBadge: (tierBadge)->
    #   self = this
    #   courseBadge = self.availableBadges[tierBadge.badge_id]
    #   loadedBadge = new TierBadgePrototype(self, angular.copy(courseBadge))
    #   self.badges[courseBadge.id] = loadedBadge # add tier badge to tier
    #   delete self.availableBadges[courseBadge.id] # remove badge from available badges on tier

    ##rubric ctrl  
    loadTierBadge: (tierBadge)->
      courseBadge = @availableBadges[tierBadge.badge_id]
      loadedBadge = new TierBadgePrototype(@, angular.copy(courseBadge))
      loadedBadge.id = tierBadge.id
      @badges[courseBadge.id] = loadedBadge # add tier badge to tier
      delete @availableBadges[courseBadge.id] # remove badge from available badges on tier
      
    # Badges
    loadTierBadges: (tierBadges)->
      angular.forEach(tierBadges, (tierBadge, index)=>
        if (@availableBadges[tierBadge.badge_id])
          @loadTierBadge(tierBadge)
      )
    #rubric ctrl
    # Badges
    addBadge: (attrs={})->
      newBadge = new TierBadgePrototype(@, attrs)
      @badges.splice(-1, 0, newBadge)
    addBadges: (tiers)->
      angular.forEach(badges, (badge,index)=>
        @loadBadge(badge)
      )
    selectBadge: ()->
      newBadge = new TierBadgePrototype(@, angular.copy(@selectedBadge), {create: true})

    deleteTierBadge: (tierBadge)->
      if confirm("Are you sure you want to delete this badge from the tier?")
        $http.delete("/tier_badges/#{tierBadge.id}").success(
          (data,status)=>
            @availableBadges[tierBadge.badge.id] = angular.copy(@$scope.courseBadges[tierBadge.badge.id])
            delete @badges[tierBadge.badge.id]
        ).error((err)->
          alert("delete failed!")
        )

    resetChanges: ()->
      @hasChanges = false
    editBadges: ()->
      @editingBadges = true
    closeBadges: ()->
      @editingBadges = false
    params: ()->
      metric_id: @metric_id,
      name: @name,
      points: @points,
      description: @description
    create: ()->
      Restangular.all('tiers').post(@params())
        .then(
          (response)=> #success
            @id = response.id
          (response)-> #error
        )
    modify: (form)->
      if form.$valid
        if @isNew()
          @create()
        else
          @update()

    update: ()->
      if @hasChanges
        Restangular.one('tiers', @id).customPUT(@params())
          .then(
            ()-> #success
            ()-> #failure
          )
        @resetChanges()
    metricName: ()->
      alert @metric.name
    delete: (index)->
      if @isSaved()
        if confirm("Are you sure you want to delete this tier?")
          $http.delete("/tiers/#{@id}").success(
            (data,status)=>
              @removeFromMetric(index)
              return true
          )
          .error((err)->
            alert("delete failed!")
            return false
          )
      else
        @removeFromMetric(index)
    removeFromMetric: (index)->
      @metric.tiers.splice(index,1) 
]