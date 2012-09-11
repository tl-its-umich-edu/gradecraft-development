// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require bootstrap-wysihtml5-all
//= require highcharts
//= require flexslider 
//= require underscore.min
//= require backbone.min
//= require_tree .

$(document).ready(function(){
  $('#some-textarea').wysihtml5();
  
  $('#gradeCurious').popover({
    placement: 'bottom'
    });
  
  // Fix input element click problem
  $('.dropdown input, .dropdown label').click(function(e) {
    e.stopPropagation();
  });
  
  	$('#scoreTotal').hide();
	$('#userBarTotal').hide();
	$('#showPossiblePts').hide();
    $('#soFarScoreToggle').hide();	

    $('a.dashboard-toggle').click(function(){
      $('.dashboard-toggle').toggle();
      return false;
	})
  

$('#course_id').change(function() { $(this).closest('form').submit(); });

$('.nav-tabs').button();

   $('.flexslider').flexslider({
      animation: "slide",
      slideshow: false,      
      controlNav: true, //Boolean: Create navigation for paging control of each clide? Note: Leave true for manualControls usage
      directionNav: true,             //Boolean: Create navigation for previous/next navigation? (true/false)
      prevText: "Previous",           //String: Set the text for the "previous" directionNav item
      nextText: "Next"
      
    });

    
	// add commas
	function addCommas(i){
		numWithCommas = i.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
		return numWithCommas;
	};	
	
	// handle 'select all' button
	$(".select-all").click(function(e){
		e.preventDefault();
		$(this).siblings().find("input").each(function(){
			$(this).attr("checked","checked");
		});
		updateProgressBar($(this));		
	});
		
	// handle 'select none' button
	$(".select-none").click(function(e){
		$(this).siblings().find("input").each(function(){
			$(this).attr("checked", false);
		});
		updateProgressBar($(this));		
	});
	
	
function removeCommas(i){
		console.log(i);
		if (i == null) {
			return 0;
		}
		else if (i.indexOf(",") >= 0){
			integer = parseInt(i.replace(/,/g, ""));
			return integer
		}
		else{
			return parseInt(i);
		}
	}; 

  
});
	
