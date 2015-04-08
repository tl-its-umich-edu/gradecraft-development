@gradecraft.factory 'TierBadgePrototype', ['$http', ($http) ->
  class TierBadgePrototype
    constructor: (tier, badge, attrs={create:false}) ->  
      @tier = tier
      @badge = badge
      if badge.name
        @name = badge.name
      @tier_id = tier.id
      @badge_id = badge.id
      @description = badge.description
      @point_total = badge.point_total
      @icon = badge.icon
      @multiple = badge.multiple
      @id = null
      if attrs.create
        @create()
 
    create: ()->
      $http.post("/tier_badges", @createParams()).success(
        (data,status)=>
          @id = data.existing_tier_badge.id
          @tier.badges[@badge_id] = @ # add tier badge to tier
          delete @tier.availableBadges[@badge_id] # remove badge from available badges on tier
          #self.selectedBadge = "" # reset selected badge
      ).error((err)->
        alert("create failed!")
        return false
      )

    createParams: ()->
      tier_id: @tier.id,
      badge_id: @badge.id
]