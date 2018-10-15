  $(function(){
    if(r_ctrl == 'deals' && r_act == 'index')
    {
      $.fn.editable.defaults.mode = 'popup';
      

      $(".ajax-lead-listing").find('th').on("click", function (event) {
        if(!$(event.target).is("span") ){
          //$(".lead-custom-drop").hide();
          event.stopImmediatePropagation();
        }
      });
      
      $(".lead-custom-drop").on("click", function(event){
        event.stopPropagation();
      });
      
          
    }
  });
 

function changePriority(id,priority,priority_id){
    $("#task_loader,.fixed_loader").show();
    $.ajax({
      url: "/change_priority",
      data: {id: id,priority_id: priority_id},
      success: function(data){ 
        //alert("Success");
        if(priority=="Hot")
          pr_cl = "hot_pri"
        else if(priority=="Warm")
          pr_cl = "warm_pri"
        else
          pr_cl = "cold_pri"
        $(".priority_label.priority_lead_"+id).removeClass("hot_pri warm_pri cold_pri").addClass(pr_cl);
        $(".priority_label.priority_lead_"+id).html(data);
        $("#task_loader,.fixed_loader").hide();
      },
      error: function(data){
        $("#task_loader,.fixed_loader").hide();
        alert('Got an error while changing priority.');
      }
    });
  }

function showIndividualLeadDetails(obj,lead_id){
    $(".lead-custom-drop").css({"left":"-3px"});
    $(".title_container").css({"display":"table"});
    //$(".lead-page").css({"padding-right":"280px","width":"100%"});
    $(".lead-page").addClass("col-md-8");
    $(".deal_popup_menu").css({"display":"table-cell"});
    $(".lead-page").addClass("pull-left");
    $(".lead-details").show();
    $(".lead-details").addClass("lead-details-in-ll");
    $(".profile-details").css({"display":"block"});
    $(".lead-cont-name").hide();
    $(".ajax-lead-listing tr").removeClass("selected_row");
    $(obj).closest("tr").addClass("selected_row");
    $(".lead-profile-icon").addClass('center-pf-icon');
    $(".contact-img-center").addClass('center-img-icon');
    $(".priority_container .black").removeClass("space-left");
    //$(".title_container").css("padding-top","0");
    $(".selected_row td").css("background","#eee !important");
    $(".lead-title-content").hide();
    $(".lead-details.lead-details-in-ll").html("<div class='loader-of-lead-details-in-ll'><img src='/assets/ajax-loader2.gif'/></div>");
    $.ajax({
      url: "/get_lead_details_in_lead_listing",
      data: {id: lead_id},
      success: function(data){ 
        //alert("Success");
        $(".lead-details.lead-details-in-ll").html(data);
        $(".lead-details.lead-details-in-ll").attr("id","lead-"+lead_id);
      },
      error: function(data){
        $("#task_loader,.fixed_loader").hide();
        alert('Got an error while getting contact details.');
      }
    });
  }

  function showLeadDetails(obj,lead_id){
    
    // When Lead details is hide, here display the div in lead listing
    if ($(".lead-details").attr("id") == "lead-"+lead_id && $(".lead-details").is(":visible") == true ){
      hideLeadDetails();

      
    }  
    //Hide the lead details in lead listing
    else{
      showIndividualLeadDetails(obj,lead_id);
    }
  }
  
  

  
function hideLeadDetails(){
    $(".lead-custom-drop").css({"left":"16px"});
    $(".title_container").css({"display":"block"});
    $(".deal_popup_menu").css({"display":"block"});
    $(".lead-details").hide();
    // $(".lead-page").css({"padding-right":"0"});
    $(".lead-page").removeClass("pull-left");
    $(".lead-page").removeClass("col-md-8");
    $(".lead-details").removeClass("lead-details-in-ll");
    $(".profile-details").css({"display":"none"});
    $(".lead-cont-name").show();
    $("tr").removeClass("selected_row");
    $(".lead-profile-icon").removeClass('center-pf-icon');
    $(".priority_container .black").addClass("space-left");
    //$(".title_container").css("padding-top","11px");
    $(".ajax-lead-listing tr td:nth-child(5)").show();
    $(".contact-img-center").removeClass('center-img-icon');
    $(".selected_row td").css("background","#fff !important");
    $(".lead-title-content").show();
  }

function changeUserLabel(id, user_label_name){
    $("#task_loader,.fixed_loader").show();
    $.ajax({
      url: "/change_user_label",
      data: {id: id,user_label_name: user_label_name},
      success: function(data){ 
        //alert("Success");
        $(".user_label.label_"+id).html(data);
        $("#task_loader,.fixed_loader").hide();
      },
      error: function(data){
        $("#task_loader,.fixed_loader").hide();
        alert('Got an error while changing user label.');
      }
    });
  }
  


function changeDealSource(id, source_id){
    $("#task_loader,.fixed_loader").show();
    $.ajax({
      url: "/change_deal_source",
      data: {id: id,source_id: source_id},
      success: function(data){ 
        if(data.length > 12)
          var source_name = data.substring(0,12) + "..."
        else
          var source_name = data
        $(".dealsource_"+id).html(source_name);
        $(".dealsource_"+id).attr("title","").attr("title",data);
        $("#task_loader,.fixed_loader").hide();
      },
      error: function(data){
        $("#task_loader,.fixed_loader").hide();
        alert('Got an error while changing user label.');
      }
    });
  }
  
function delete_opportunity(id){
    $.ajax({
      type: "GET",
      url: "/delete_opportunity_confirm",
      data: {deal_id: id},
      dataType: 'json',
      async: false,
      beforeSend: function(){
        $("#task_loader,.fixed_loader").show();
      },
      success: function(data)
      {
      },
      error: function(data) {
        $("#task_loader,.fixed_loader").hide();
      },
      complete: function(data) {
        $("#deleteOppModal").modal("show");
        $('#deleteOppContent').html(data.responseText);
        $("#task_loader,.fixed_loader").hide();
      }
    });
  }
  