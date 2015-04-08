$(document).ready(function(){

  if($("#dashboard-timeline").length) {
    $.ajax({
        type: 'GET',
        url: '/info/timeline_events',
        dataType: 'json',
        contentType: 'application/json',
        success: function (json) {
            createTimeline(json);
        }
     });
  }


  function createTimeline(source){
    $("#loading").hide();
    //get the events.json format from https://github.com/VeriteCo/TimelineJS#file-formats
    var timeline_dates = source.timeline.date;
    var start_index = 1;
    var target_date = new Date(); 
    console.log(target_date);
    for(x in timeline_dates) {
      var slide_date = new Date( timeline_dates[x].startDate );
      console.log(timeline_dates[x]);
      if( slide_date < target_date ) {
        start_index++
      };
    }

      createStoryJS({
        type: 'timeline',
        width: '100%',
        height: '600',
        hash_bookmark: 'true',
        source: source,
        embed_id: 'time_line',
        start_at_slide: start_index
      });
  }
});
