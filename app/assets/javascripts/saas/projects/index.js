$(function(){
    
  $.removeCookie = function (key, options) {
    if ($.cookie(key, options) === undefined) { // this line is the fix
        return false;
    }

    // Must not alter options, thus extending a fresh object...
    $.cookie(key, '', $.extend({}, options, { expires: -1 }));
    return !$.cookie(key);
  };
  if(r_ctrl == 'projects' && r_act == 'index')
  {
    fillProjectsListing()
  }
  $("#select_all").prop("checked",false);
  $("#select_all").on('click', function(){
    if($(this).is(":checked")){
      var vals="";
      $(".chb-in-ll").each(function(i){
        $(this).prop("checked",true);
        vals = vals + $(this).val().toString() + ",";
      })
      $("#project_ids_to_complete").val(vals);
      $("#project_ids_to_archive").val(vals);
    }else{
      $(".chb-in-ll").each(function(i){
        $(this).prop("checked",false);
      })
      $("#project_ids_to_complete").val("");
      $("#project_ids_to_archive").val("");
    }
  })

  $("#ProjectListingDropdown").click(function() {  
    var isChecked = $('input[name="project_check_box"]:checked').length;
    if(isChecked > 0){
      $("#ProjectListing_sub_menu").toggle();
    }
  });
  
  $(".create_project_temp").on("click", function(){
    var has_class = $(this).hasClass('contact_create_project')
    $.ajax({
      url: '/projects/open_project_popup',
      type: 'GET',
      async: true,
      beforeSend: function(){
        $("#task_loader, .fixed_loader").show();
      },success: function(res) {
        $("#project-form-div").html(res);
        $("#projectModal").find(".modal-title").html('<span class="fal fa-briefcase"></span> CREATE NEW PROJECT');
        $("#task_loader, .fixed_loader").hide();
        if(has_class){
          $('#project_linked_with').val('Contact');
          $('.prj-individual-contact-div').show();
        }
      },
      error: function(data){
        $("#task_loader, .fixed_loader").hide();
      },
    });
  })
  $(".convert_to_project").on("click", function(){
    var has_class = $(this).hasClass('contact_create_project');
    var contact_id = $("#lead_contact_id").val();
    var contact_type = $("#lead_contact_type").val();
    var deal_id = $("#opportunity_id").val()
    $.ajax({
      url: '/projects/open_project_popup?contact_id=' + contact_id+'&deal_id='+  deal_id+ '&contact_type='+contact_type,
      type: 'GET',
      async: true,
      data: {contact_id: contact_id, deal_id: deal_id, contact_type: contact_type},
      beforeSend: function(){
        $("#task_loader, .fixed_loader").show();
      },success: function(res) {
        $("#project-form-div").html(res);
        $("#projectModal").find(".modal-title").html('<span class="fal fa-briefcase"></span> CREATE NEW PROJECT');
        $("#task_loader, .fixed_loader").hide();
        $('#projectModal').modal('show')
        $('#link_lead_yes').prop('checked',true);
        $('#lead_section').show();
        $('#project_linked_with').val('Opportunity');
        showHideTypeRelationProject('Opportunity')
        $("#new_project").find("#project_individual_contact_id").select2('val',$("#lead_contact_id").val());
        
        $("#new_project").find("#project_deal_id").select2('val',$("#opportunity_id").val())
        $('#project_individual_contact_id').prop('required',true).css({'background':'#eee','cursor':'not-allowed'});
        $('#project_deal_id').prop('required',true).css({'background':'#eee','cursor':'not-allowed'});
        $('#project_deal_id option').hide();
        $('#project_individual_contact_id option').hide();
        $('#link_lead_no').prop('disabled','disabled');
        $('#link_lead_no').next().find('span').css('cursor','not-allowed');
        
        
      },
      error: function(data){
        $("#task_loader, .fixed_loader").hide();
      },
    });
  })
  

})
  function display_hide_submenu(type)
  {
    if(type == "created")
    {
      reser_all_submenu();
      $('.cre_arw').show();
      $('#cr').show();

    }
    else if(type == "assigned")
    {
      reser_all_submenu();
      $('.asg_arw').show();
      $('#asg').show();
    }
    
    else if(type == "anytime")
    {
      reser_all_submenu();
      $('.any_arw').show();
      $('#any').show();
    }
    else if(type == "last")
    {
      reser_all_submenu();
      $('.lst_arw').show();
      $('#lat').show();
    }
   else if(type == "lead")
    {
      reser_all_submenu();
      $('.lead_arw').show();
      $('#lead').show();
    }
    else if(type == "priority")
    {
      reser_all_submenu();
      $('.pri_arw').show();
      $('#pr').show();
    }
    else if(type == "status")
    {
      reser_all_submenu();
      $('.sta_arw').show();
      $('#st').show();
    } 
    else if(type == "proj")
    {
      reser_all_submenu();
      $('.proj_arw').show();
      $('#proj').show();
    }
    else if(type == "proj_stage")
    {
      reser_all_submenu();
      $('.proj_stage_arw').show();
      $('#proj_stage').show();
    }
    $(".main_menu").show()
  }
  function reser_all_submenu()
  {
   //$(".main_menu").toggle(400)
   $('.cre_arw').hide();
   $('#cr').hide();
   $('.asg_arw').hide();
   $('#asg').hide();   
   $('.any_arw').hide();
   $('#any').hide();
   $('.lst_arw').hide();
   $('#lat').hide();
   $('.lead_arw').hide();
   $('#lead').hide();
   $('#asg').hide();
   $('.pri_arw').hide();
   $('#pr').hide();
   $('.sta_arw').hide();
   $('#st').hide();
   $('.proj_arw').hide();
   $('#proj').hide();
   $('.proj_stage_arw').hide();
   $('#proj_stage').hide();
  }


  function chk_radio_button(id, type, inputNode){
    if(type == "created")
    {
      $("input:checkbox[name='created_by']:checked").each(function() {
        var values = $(this).val();
        $("#cre_by_"+values).attr("checked", true);
      });
    }
    else if(type == "assigned")
    {
     $("input:checkbox[name='assg_by']:checked").each(function() {
      var values = $(this).val();
      $("#assg_by_"+values).prop("checked", true);
     });
    }
    else if(type == "any")
    {
     $("#"+id).prop("checked", true);
    }
    else if(type == "last")
    {
     $("#"+id).prop("checked", true);
    }
    else if(type == "lead")
    {
     $("input:checkbox[name='lead']:checked").each(function() {
       var values = $(this).val();
       $("#lead_"+values).attr("checked", true);
     });
    }
    multi_filter_projects();
  }

  function multi_filter_projects(get_stage,get_stage_val,get_stage_txt) {
    var cre_by_val = "";
    var lead_val = "";
    var asg_by_val = "";
    $("input:checkbox[name='created_by']:checked").each(function(i) {
      var values = $(this).val() + "|";
      cre_by_val += values;
    });    
    console.log(cre_by_val)
    $("input:checkbox[name='assg_by']:checked").each(function(i) {
      var assg_vals = $(this).val() + "|";
      asg_by_val += assg_vals;
    });
    $("input:checkbox[name='lead']:checked").each(function(i) {
      var values = $(this).val() + "|";
      lead_val += values;
    });

    var dt_range = $("input:radio[name='anytime']:checked").val();
    var last_touch = $("input:radio[name='last_touch']:checked").val();
    var dt_range_from = $("#project_from").val();
    var dt_range_to = $("#project_to").val();
    if(dt_range == "Custom Date")
      $("#custom_date").show();
    else
      $("#custom_date").hide();
    var posturl="/projects_list";
    divid= "view_content";
    $("#filter_get_val").val(1);

    var cre_by = false;
    var asg_by = false;
    var lead = false;
    var daterange = false;
    var last_tch = false;
    var dtrange_from = false;
    var dtrange_to = false;

    if(cre_by_val != "" && typeof cre_by_val != 'undefined'){

      cre_by = true;
      var cre_by_txt = "";
      $("input:checkbox[name='created_by']:checked").each(function(i) {
        cre_by_txt += $('#cre_by_'+$(this).val()).attr("c_name") + '|';
      });
      cre_by_txt = cre_by_txt.slice(0,-1);
      document.cookie="cre_by=true"
      document.cookie="cre_by_val="+cre_by_val;
      document.cookie="cre_by_txt="+cre_by_txt;
      $(".tag_filter").show();
      $(".created_by_tag").show();
      $("#created_by_tag_txt").html(cre_by_txt.split('|').join(','));
    }

    if(dt_range != "" && typeof dt_range != 'undefined'){
     if(dt_range != "Custom Date"){
      $("#project_from").val('');
      $("#project_to").val('');
      $(".date_range_tag").hide();
      $.removeCookie("dtrange_from");
      $.removeCookie("dt_range_from");
      $.removeCookie("dt_range_frm_txt");
      $.removeCookie("dtrange_to");
      $.removeCookie("dt_range_to");
      $.removeCookie("dt_range_to_txt");
      daterange = true;
      date_txt=dt_range

      document.cookie="daterange=true";
      document.cookie="dt_range="+dt_range;
      document.cookie="dt_range_txt="+date_txt;
      $(".tag_filter").show();
      $(".date_tag").show();
      $("#date_tag_txt").html(date_txt)
    }
    else
    {
     if(dt_range_from != "" && dt_range_to != ""){
     daterange = false;
     $(".date_tag").hide();
     $.removeCookie("daterange");
     $.removeCookie("dt_range");
     $.removeCookie("dt_range_txt");
     dtrange_from = true;
     dtrange_to = true;
     from_date=$("#project_from").val();
     to_date=$("#project_to").val();

     document.cookie="dtrange_from=true";
     document.cookie="dt_range_from="+dt_range_from;
     document.cookie="dt_range_frm_txt="+from_date;

     document.cookie="dtrange_to=true";
     document.cookie="dt_range_to="+dt_range_to;
     document.cookie="dt_range_to_txt="+to_date;
     $(".tag_filter").show();
     $(".date_range_tag").show();
     $("#from_tag_txt").html(from_date +" to "+ to_date);
    }else{
     $(".date_range_tag").hide();
     $.removeCookie("dtrange_from");
     $.removeCookie("dt_range_from");
     $.removeCookie("dt_range_frm_txt");
     $.removeCookie("dtrange_to");
     $.removeCookie("dt_range_to");
     $.removeCookie("dt_range_to_txt");
    }
    }
    }else if(dt_range_from == "" || dt_range_to === 'undefined'){
       daterange = false;

       $(".date_tag").hide();
       $.removeCookie("daterange");
       $.removeCookie("dt_range");
       $.removeCookie("dt_range_txt");
       $(".date_range_tag").hide();
       $.removeCookie("dtrange_from");
       $.removeCookie("dt_range_from");
       $.removeCookie("dt_range_frm_txt");
       $.removeCookie("dtrange_to");
       $.removeCookie("dt_range_to");
       $.removeCookie("dt_range_to_txt");
    }


    if(cre_by_val == "" || typeof cre_by_val === 'undefined'){

      $(".created_by_tag").hide();
      $.removeCookie("cre_by");
      $.removeCookie("cre_by_val");
      $.removeCookie("cre_by_txt");
    }
    if(asg_by_val != "" && typeof asg_by_val != 'undefined'){

      asg_by = true;
      //asg_by_txt=$('#assg_by_'+asg_by_val).attr("a_name");

      var asg_by_txt = "";
      $("input:checkbox[name='assg_by']:checked").each(function() {
        asg_by_txt += $('#assg_by_'+$(this).val()).attr("a_name") + '|';
      });
      asg_by_txt = asg_by_txt.slice(0,-1);
      document.cookie="asg_by=true";
      document.cookie="asg_by_val="+asg_by_val;
      document.cookie="asg_by_txt="+asg_by_txt;
      $(".tag_filter").show();
      $(".assigned_to_tag").show();
      $("#assigned_to_tag_txt").html(asg_by_txt.split('|').join(','))
    }
    if(asg_by_val == "" || typeof asg_by_val === 'undefined'){

      $(".assigned_to_tag").hide();
      $.removeCookie("asg_by");
      $.removeCookie("asg_by_val");
      $.removeCookie("asg_by_txt");
    }
    if(lead_val != "" && typeof lead_val != 'undefined'){

      lead = true;
      var lead_txt = "";
      $("input:checkbox[name='lead']:checked").each(function() {
        lead_txt += $('#lead_'+$(this).val()).attr("a_name") + '|';
      });
      lead_txt = lead_txt.slice(0,-1);
      document.cookie="lead=true";
      document.cookie="lead_val="+lead_val;
      document.cookie="lead_txt="+lead_txt;
      $(".tag_filter").show();
      $(".lead_tag").show();
      $("#lead_tag_txt").html(lead_txt.split('|').join(','))
    }
    if(lead_val == "" || typeof lead_val === 'undefined'){

     $(".location_tag").hide();
     $.removeCookie("lead");
     $.removeCookie("lead_val");
     $.removeCookie("lead_txt");
    }


    if(cre_by_val == "" && lead_val == "" && asg_by_val == "" && lead_val != 1 && (last_touch == "") && dt_range_from == "" && dt_range_to == "" && ((dt_range == "" || typeof dt_range === 'undefined') && dt_range != "Custom Date")){
      $('.reset_tag').hide();
      $(".tag_filter").hide();
    }
    else if(dt_range == "Custom Date" &&(dt_range_from == "" && dt_range_to == ""))
    {
     $('.reset_tag').hide();
    }
    else if(typeof cre_by_val === 'undefined' && typeof lead_val === 'undefined' && typeof asg_by_val === 'undefined' && typeof dt_range === 'undefined' && (typeof dt_range_from === 'undefined' || dt_range_from == "") && (typeof dt_range_to === 'undefined' || dt_range_to == ""))
    {
      $('.reset_tag').hide();
    }
    else{
      $('.reset_tag').show();
      $(".tag_dd").show();
    }
    console.log(cre_by)
    console.log(cre_by_val)
    console.log(asg_by)
    if((typeof cre_by_val != "undefined" || cre_by_val != "") || (typeof asg_by_val != "undefined" || asg_by_val != "") || (typeof lead_val != "undefined" || lead_val != "") || (typeof dt_range != 'undefined' && dt_range != "Custom Date"))
    {
      $.ajax( {
        type: "POST",
        url: posturl ,
        data: {cre_by: cre_by, cre_by_val: cre_by_val, lead: lead, lead_val: lead_val, asg_by: asg_by, asg_by_val: asg_by_val, daterange: daterange, dt_range: dt_range, dtrange_from: dtrange_from,dt_range_from: dt_range_from,dtrange_to: dtrange_to,dt_range_to: dt_range_to},
        success: function(result) {
          //$(".nav.nav-tabs").find("li").removeClass("active");
          //$(".tag_filter").show();
          //$("#all_tab").removeClass("active");

          $("#"+divid).html("");
          $("#"+divid).html(result);
          $("#task_loader,.fixed_loader").hide();
        }
      });
     }
    else if(dt_range_from != "" && dt_range_to != "")
    {
       $.ajax( {
        type: "POST",
        url: posturl ,
        data: {cre_by: cre_by, cre_by_val: cre_by_val, asg_by: asg_by, asg_by_val: asg_by_val, loc: loc, loc_val: loc_val, priority: priority, priority_val: priority_val,next: next, next_val: next_val, daterange: daterange, dt_range: dt_range, last_touch: last_touch, dtrange_from: dtrange_from,dt_range_from: dt_range_from,dtrange_to: dtrange_to,dt_range_to: dt_range_to,tag:tag_val, stage: stage, stage_val: stage_val, user_label: user_label, user_label_val: user_label_val,label_type:is_label},
        success: function(result) {
          $("#"+divid).html("");
          $("#"+divid).html(result);
        }
      });
    }
    else if(cre_by_val == "" && asg_by_val == "" && dt_range == "" && (dt_range_from == "" || dt_range_to == ""))
    {

       $.ajax( {
        type: "POST",
        url: posturl ,
        data: {cre_by: cre_by, cre_by_val: cre_by_val, asg_by: asg_by, asg_by_val: asg_by_val, daterange: daterange, dt_range: dt_range, dtrange_from: dtrange_from,dt_range_from: dt_range_from,dtrange_to: dtrange_to,dt_range_to: dt_range_to,tag:tag_val},
        success: function(result) {
          $("#"+divid).html("");
          $("#"+divid).html(result);
        }
      });

    }
    else if(typeof cre_by_val === 'undefined' && typeof asg_by_val === 'undefined'&& typeof dt_range === 'undefined' && (dt_range_from == "" || dt_range_to == "") && typeof stage_val === 'undefined')
    {
       $.ajax( {
        type: "POST",
        url: posturl ,
        data: {cre_by: cre_by, cre_by_val: cre_by_val, asg_by: asg_by, asg_by_val: asg_by_val, daterange: daterange, dt_range: dt_range, dtrange_from: dtrange_from,dt_range_from: dt_range_from,dtrange_to: dtrange_to,dt_range_to: dt_range_to},
        success: function(result) {
          $("#"+divid).html("");
          $("#"+divid).html(result);
        }
      });
    }
  }


  
  function reset_filter(id,class_n,stage_f){
    $('.'+id+"_tag").hide();
    if(id == "date_range")
    {
      $('.'+class_n).removeAttr('checked');
      $('#project_from').val('');
      $('#project_to').val('');
    }
    else if(id == "stage"){
      $('.'+class_n).removeAttr('checked');
      $('.ui-state-default').removeClass('btn-highlighed');
      $('.btn-check-sign').removeClass('btn-check-sign');
    }
    else
    {
      $('.'+class_n).removeAttr('checked');
    }
    $("#show_filter_dealmsg").html('');

    $("#filter_get_val").val(0);
   
    multi_filter_projects();
  }

  function reset_all_filter(){
    $("#filter_get_val").val(0);
    $('.created_by_tag').hide();
    $('.assigned_to_tag').hide();
    $('.reset_tag').hide();
    $('.tag_filter').hide();
    $('.cre_by_c').removeAttr('checked');
    $('.lead').removeAttr('checked');
    $('.asg_by_c').removeAttr('checked');
    $('.any_time').removeAttr('checked');

    $('#project_from').val('');
    $('#project_to').val('');
    //$("#lead").val(0);
    $.each(["cre_by","cre_by_val","cre_by_txt", "lead","lead_val","lead_txt","daterange","dt_range","dt_range_txt","asg_by","asg_by_val","asg_by_txt","last_touch","last_tch","last_touch_txt","dtrange_from","dt_range_from","dt_range_frm_txt","dtrange_to","dt_range_to","dt_range_to_txt"], function( index, value ) {
       $.removeCookie(value);
    });
    multi_filter_projects();
  }
  function reset_filter(id,class_n,stage_f){
    $('.'+id+"_tag").hide();
    if(id == "date_range")
    {
      $('.'+class_n).removeAttr('checked');
      $('#project_from').val('');
      $('#project_to').val('');
    }
    else
    {
      $('.'+class_n).removeAttr('checked');
    }
    $("#show_filter_dealmsg").html('');

    $("#filter_get_val").val(0);

    if(id == "lead"){
      $("#lead").val(0);
      $('.lead_tag').hide();
      $.removeCookie("lead");
    }
  
    multi_filter_projects();
    $("#task_loader,.fixed_loader").hide();
  }
  function reset_filter_val(){
    $("#filter_get_val").val(0);
  }

  $(window).click(function() {
    $('.main_menu').hide();
    // $('.project-custom-drop').hide();
  });

  $('.main_menu').click(function(event){
    event.stopPropagation();
  });

  

  function other_chk_box(){
    //check header checkbox if all checkbox are checked and vice versa
    var check_box_count = $(".chb-in-ll").length;
    var check_all_count = 0;
    $(".chb-in-ll").each(function(i){
      if($(this).is(":checked")){
        check_all_count = check_all_count + 1;
      }
    })
    if(check_box_count == check_all_count){
      $("#select_all").prop("checked",true);
    }else{
      $("#select_all").prop("checked",false);
    }
    var $cbs = $('input[name="project_check_box"]');
    var total = 0;
    $cbs.each(function() {
      if (this.checked){
          total ++;
      }
    });
    if(total > 0){
      $("#ProjectListingLabel").removeClass("label_arrow")
      $("#ProjectListingLabel").addClass("label_arrow_active")
      $("#ProjectListing_Dropdown").attr("data-toggle", "dropdown")
    }else{
      $("#ProjectListingLabel").addClass("label_arrow")
      $("#ProjectListingLabel").removeClass("label_arrow_active")
      $("#ProjectListing_Dropdown").removeAttr("data-toggle", "dropdown");
      $(".DataTables_sort_wrapper").removeClass("open")
    }
  var checkboxes = document.getElementsByName('project_check_box');
  var vals = "";
  for (var i=0, n=checkboxes.length;i<n;i++) {
   if (checkboxes[i].checked) 
   {
    vals += checkboxes[i].value+ ","
   }
  }
  $("#project_ids_to_complete").val(vals);
  $("#project_ids_to_archive").val(vals);  
  };

  $("#complete_projects").bind("ajax:complete", function(evt, data, status, xhr){
    $('#confirmProjectComplete').modal('hide');
    window.location.reload();
  });  

  $("#archive_projects").bind("ajax:complete", function(evt, data, status, xhr){
    $('#confirmProjectArchive').modal('hide');
    window.location.reload();
  }); 
  $(".show_onboarding.show").click(function(){
    $(".user_onbording_container").hide();
    $(".onboarding_page").show();
    $(".onboarding_projects").show();
  })

function  update_project_users(id){
    var add_users = $('#hdn_add_users').val();
    var remove_users = $('#hdn_remove_users').val();
    $.ajax({
      type: "POST",
      url: "/update_project_users",
      data: {remove_user_ids: remove_users, add_user_ids: add_users, id: id},
      beforeSend: function(){
        $('#task_loader,.fixed_loader').show();
      },
      success: function(result) {
        window.location.reload();
      }
    });
  }
function checkCommentsExists()
{
  if($("#comment_comment").val().trim() == "" || $("#comment_comment").val().trim() == null || $("#comment_comment").val().trim() == undefined)
  {
    $(".comment_err_msg").html("Please enter comment!");

    return false;
  }
  else
  {
    $(".comment_err_msg").html("");

    return true;
  }
}
function fillProjectsListing()
{
  oTable_other= $('#projectDataTable').dataTable( {
    sPaginationType: "bootstrap",
    bJQueryUI: true,
    "sDom": '<"dtTop dtTables">rt<"dtBottom"><"dtInfo fl"i><"dtPagination fr"p>',
    aoColumns: [null,null,{sWidth: '240px'},null,null,null,null,null,null],
    iDisplayLength: 20,
    bServerSide: true,
    "bSort": true,
    "bFilter": true,
    "bStateSave": true,
    sAjaxSource: $('#projectDataTable').data('source'),
    oLanguage: {
    oPaginate: {
      sPrevious: "Prev"
    }
    },
    aoColumnDefs: [
    
    {
      aTargets: [0],
      bSortable: false,
      mRender: function (data, type, row ) {
       return "#"+row[0]
      }
    },
    {
      aTargets: [1],
      bSortable: false,
      mRender: function (data, type, row ) {
      str="<div class='dropdown' > <a class='dropdown-toggle' data-toggle='dropdown' aria-expanded='true' onclick=\"$('#clicked_button_ref').val('listmenu');\" title='Actions' style='cursor:pointer;z-index: 0;'><i class='fa fa-ellipsis-h'></i></a>";

      dropdownstr="<div class='checkbox checkbox-inline'><input type='checkbox' value='" + row[1] +"' id='prj-" + row[1] +"' name='project_check_box' class='chk_box_class chb-in-ll' onclick='other_chk_box()'><label for='prj-" + row[1] +"'></label></div>"
      var act = ""
      if(row[18] != 'Administrative')
      {
        if(row[14]=="true"){
           act = "<li><a rel='tooltip' onclick=\"update_project('"+row[1]+"','reopen')\" href='javascript:void(0)' title='Re-open this project'><span class='fal fa-lock-open'></span> Re-open</a></li>"
        }else{
           act = "<li><a rel='tooltip' onclick=\"update_project('"+row[1]+"','complete')\" href='javascript:void(0)' title='Mark this project as \"Complete\"'><span class='fal fa-clipboard-list'></span> Complete</a></li>"
        }
      }
      str+= "<ul class='dropdown-menu animated flipInX m-t-xs' >"+act
      if(row[18] != 'Administrative')
      {
      str+= "<li><a onclick=\"add_project_user('"+row[1]+"')\" href='javascript:' title='Add new Users to this project' style='cursor:pointer;'><span class='fal fa-users filter_created_by'></span> Add Users</a></li><li><a rel='tooltip' onclick=\"archive_project('"+row[1]+"')\" href='javascript:void(0)' title='Delete this project'><span class='glyphicon glyphicon-trash'></span> Delete</a></li>"
      }
      str+= "</ul></div>"+ dropdownstr ;

      return str
      }     
    },
    {
      aTargets: [2],
      bSortable: false,
      mRender: function (data, type, row ) {
      if(row[2] != ""){
        if(row[2].length > 25){
        var proj_name = row[2].substring(0,22) + "..."
        }else{
        proj_name = row[2];
        }
      }

      if(row[15] != ""){
        if(row[15].length > 15){
        var name = row[15].substring(0,15) + "..."
        }else{
        name = row[15];
        }
      }
      else
      {
        name = "";
      }
      return "<a href='/projects/" + row[1]  + "' class='change-lead-color-ll' title='"+row[2]+"'>" + proj_name + "</a><br/>Managed by <span title='"+row[10]+"'>" + name + "<br>on " + row[11]
      }
    },
    {
      aTargets: [3],
      bSortable: false,
      mRender: function (data, type, row ) {
        var str =  row[16] 
        if(row[16] == "Opportunity")
        { str += "<br>" + row[4] + "<br> Contact:" + row[3]}
        else if (row[16] == "Contact")
        { str += "<br>" + row[3]}
        else if (row[16] == "Organization")
        { str +=  "<br>" + row[17]}
        return str;
      }
    },
    // {
    //   aTargets: [4],
    //   bSortable: false,
    //   mRender: function (data, type, row ) {
    //    return row[3]
    //   }
    // },
    {
      aTargets: [4],
      bSortable: false,
      mRender: function (data, type, row ) {
       //return row[5]
       if(row[5] != ""){
        if(row[5].length > 17){
          var desc = row[5].substring(0,14) + "...";
          var desc_title = row[5];
        }else{
          var desc = row[5];
          var desc_title = "";
        }
          return "<span title='"+desc_title+"'>"+desc+"</span>"
       }

      }
    },
    {
      aTargets: [5],
      bSortable: false,
      mRender: function (data, type, row ) {
       return row[6]
      }
    },
    {
      aTargets: [6],
      bSortable: false,
      mRender: function (data, type, row ) {
       return row[7]
      }
    },
    {
      aTargets: [7],
      bSortable: false,
      mRender: function (data, type, row ) {
       return row[8]
      }
    },
    {
      aTargets: [8],
      bSortable: false,
      mRender: function (data, type, row ) {
       return row[9] + "<br/><a rel='tooltip' class='change-color-ll' href='projects/" + row[1] + "/jobs/new' data-toggle='modal' data-id='" + row[1] + "'>+ Add a Job</a>"
      }
    },
    ]
  });
}


function fillProjectJobFields(project_id)
  {

    //// Get project assigned users
    // $.ajax( {
    //   type: "POST",
    //   url: "/projects/" + project_id + "/get_assigned_to_users",
    //   dataType: 'json',
    //   beforeSend: function(){
    //     $('#task_loader,.fixed_loader').show();
    //   },
    //   success: function(result) {
    //     if(result.status == "success")
    //     {
    //       var opts = "";

    //       var notify_emails="<span class='modal-checkbox checkbox checkbox-inline'><input id='checkAll' name='checkAll' type='checkbox' value=''><label for='checkAll'><span></span>All</label></span>";

    //       for (var i = 0; i < result.users.length; i++) {
    //           opts += "<option value='" + result.users[i][1].toString()+ "'>" + result.users[i][0].toString() + "</option>";
    //           notify_emails += "<span class='modal-checkbox checkbox checkbox-inline notify-email-job'><input id='user_" + result.users[i][1].toString() + "'  name='notify_email_ids' type='checkbox' value='" + result.users[i][1].toString() + "'><label for='user_" + result.users[i][1].toString() + "' ><span></span> " + result.users[i][0].toString() + "</label></span>";
    //       }
    //       $('#project_job_assigned_to option').remove();
    //       $("#project_job_assigned_to").append(opts);

    //       // Show in notify via email
    //       $("#assigned_to_checkboxes").html("")
    //       $("#assigned_to_checkboxes").html(notify_emails)
    //       //change the action of the form - because it will not get the project id 
    //       $("#new_project_job").attr("action","/projects/" + project_id+"/jobs")
          
    //       $("#project_job_project_id").val(project_id)

    //     }
    //   },
    //   error: function(res) {
    //       alert("Some error has been occured.");
    //       $('#task_loader,.fixed_loader').hide();
    //   },
    //   complete: function(res){
    //     $('#task_loader,.fixed_loader').hide();
    //   }
    // });
  }