@gradecraft.factory 'MetricBadgePrototype', ->
  # deprecated
  # class MetricBadgePrototype
  #   constructor: (metric, badge, attrs={}) ->
  #     @metric = metric
  #     @badge = badge
  #     @name = badge.name
  #     @metric_id = metric.id
  #     @badge_id = badge.id
  #     @description = badge.description
  #     @point_total = badge.point_total
  #     @icon = badge.icon
  #     @multiple = badge.multiple
 
  #   create: ()->
  #     self = this
 
  #     $http.post("/metric_badges", self.createParams()).success(
  #       (data, status)->
  #         self.id = data.existing_metric_badge.id
  #     )
  #     .error((err)->
  #       alert("create failed!")
  #       return false
  #     )
 
  #     createParams: ()->
  #       metric_id: this.metric.id,
  #       badge_id: this.badge.id