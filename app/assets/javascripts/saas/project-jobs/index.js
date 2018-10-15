$(function(){
  if(r_ctrl == 'project_jobs' && r_act == 'index')
  {
    //fillProjectJobsListing()
  }
  $("#project_job_name").keyup(function() {
    var name = $("#project_job_name").val();
    if($.trim(name) == ''){
      $('#quick_job_btn').prop("disabled",true);
    }else{
      $('#quick_job_btn').removeAttr("disabled");
    }
  });  
});
function initializeProjectJobsActions()
{
  $("#select_all_jobs").prop("checked",false);
  $("#select_all_jobs").on('click', function(){
    if($(this).is(":checked")){
      var vals="";
      $(".chb-in-ll").each(function(i){
        $(this).prop("checked",true);
        vals = vals + $(this).val().toString() + ",";
      })
      $("#resolve_job_ids").val(vals);
      $("#close_job_ids").val(vals);
    }else{
      $(".chb-in-ll").each(function(i){
        $(this).prop("checked",false);
      })
      $("#resolve_job_ids").val("");
      $("#close_job_ids").val(vals);
    }
  })
}
function fillProjectJobsListing()
{
  var show_lead_details = $("#show_lead_details").val() == "true" ? true : false;   
    oTable_projects= $('#projectJobDataTable').dataTable( {
      sPaginationType: "bootstrap",
      bJQueryUI: true,
      oLanguage: {"sLengthMenu": "_MENU_" },
      
      "bProcessing": true,
      "sDom": '<"dtTop dtTables">rt<"dtBottom"><"dtInfo fl"i><"dtPagination fr"p>',
      iDisplayLength: 20,
      bServerSide: true,
      "bSort": true,
      "bFilter": true,
      "bStateSave": true,
      sAjaxSource: $('#projectJobDataTable').data('source'),
      oLanguage: { 
        "sSearch": "" ,
        oPaginate: {
          sPrevious: "Prev"
        }
      },
      aoColumnDefs: [
        {
          aTargets: [0],
          bSortable: true,
          bVisible: true,
          mRender: function (data, type, row ) {
           $("#"+ r_pg_tab + "Badge").html("(0)");
           $("#"+ r_pg_tab + "Badge").html('(' + row[17] + ')');
           
           //console.log(str)
           return "#"+row[0] ;
          }
        },
        {
          aTargets: [1],
          bSortable: false,
          bVisible: true,
          mRender: function (data, type, row ) {
          str = '<span class="dropdown" ><a class="dropdown-toggle" data-toggle="dropdown" aria-expanded="false" href="javascript:"><small class="text-muted"><b class="caret"></b></small></a>'
          // <div><div class="deal_set dropdown-toggle more-in-ll tooltip tooltipstered" data-toggle="dropdown"  style="cursor:pointer;z-index: 0 !important;"></div><div class="cb"></div><br>';
          str += '<ul class="dropdown-menu  animated flipInX m-t-xs" ><li><a href="/projects/' + row[10] + '/jobs/' + row[1] + '/edit"><i class="pe-7s-pen edit-job"></i>Edit Job</a></li>'
          if(row[8] != 'Closed')
          {
            str += "<li><a href='javascript:void(0)' onclick=\"update_job_status(" + row[1] + ", 'Closed')\" title='Close'><span class='fal fa-check close-job'></span>Close</a></li>"

          }
          if(row[8] != 'Resolved')
          {
            str += "<li><a href='javascript:void(0)' onclick=\"update_job_status(" + row[1] + ", 'Resolved')\" title='Resolve'><span class='fal fa-flag resolve-job'></span>Resolve</a></li>"
          }
          // comment
          str += "<li><a href='/projects/" + row[10] + "/jobs/" + row[1] + "#comments' title='Comment'><span class='fal fa-comment reply'></span>Comment</a></li>"
          // add to a job group
           str += "<li><a href='javascript:void(0)' onclick=\"getProjectJobGroups(" + row[1] + "," + row[10] + ")\" title='Move to Job Group'><span class='fal fa-person-carry move-jobgroup'></span>Move to Job Group</a></li>"
          
          // enter time log
          str += '<li><a data-toggle="modal" href="#timeLogModal" onclick="get_time_log_form('+ row[1] +')"><span class="fal fa-clock start-timer"></span>Time Entry</a></li>'
          str += '</ul>';
           return  str + "</span>" +"<div class='checkbox checkbox-inline '><input type='checkbox' value='" + row[1] +"'  name='job_check_box' class='chk_box_class chb-in-ll' onclick='other_chk_box()'><label></label></div>" ;
          }
        },
        {
          aTargets: [2],
          bSortable: true,
          mRender: function (data, type, row ) {
           if(row[13] != ""){
             if(row[13].length > 15){
              var name = row[13].substring(0,15) + "..."
             }else{
              name = row[13];
             }
           }
           if(row[20] != ""){
              var cus_cls = "strike-cls"
           }else if(row[19] != ""){
              var cus_cls = "resolved-cls"
           }else{
              var cus_cls = ""
           }
           return "<div class='"+cus_cls+"'><a href='/projects/" + row[10] + "/jobs/" + row[1] + "' class='proj_link_colour'>" + row[2] + "</a><br><span style='font-size: 10px;'>Created by <span title='"+row[13]+"'>"+name+"</span> on "+row[14]+"</span></div>"
          }
        },
        {
          aTargets: [3],
          bSortable: false,
          bVisible:show_lead_details,
          bSearchable:show_lead_details,
          mRender: function (data, type, row ) {
            if(row[3] != ""  && row[3] != "NA"){
             if(row[3].length > 15){
              var name_opportuntiy = row[3].substring(0,15) + "..."
             }else{
              name_opportuntiy = row[3];
             }
           }
           else
           {
            name_opportuntiy = ""
           }
           if(row[4] != "" && row[4] != "NA"){
             if(row[4].length > 15){
              var name_contact = row[4].substring(0,15) + "..."
             }else{
              name_contact = row[4];
             }
           }
           else
           {
            name_contact = ""
           }
            return "<a href='/leads/"+row[15]+"' title='"+row[3]+"'>"+name_opportuntiy+"</a><br>" + "<a href='/contacts/"+row[16]+"' title='"+row[4]+"'>"+name_contact+"</a>"
          }
        },
        // {
        //   aTargets: [4],
        //   bSortable: false,
        //   bVisible:show_lead_details,
        //   bSearchable:show_lead_details,
        //   mRender: function (data, type, row ) {
        //    if(row[4] != ""){
        //      if(row[4].length > 15){
        //       var name = row[4].substring(0,15) + "..."
        //      }else{
        //       name = row[4];
        //      }
        //    }
        //     return "<a href='/contacts/"+row[16]+"' title='"+row[4]+"'>"+name+"</a>"
        //   }
        // },
        {
          aTargets: [4],
          bSortable: false,
          mRender: function (data, type, row ) {
           return row[21]
          }
          
        },
        {
          aTargets: [5],
          bSortable: false,
          mRender: function (data, type, row ) {
            if(row[11] != ''){
              if(row[11].length > 12)
                  var user = row[11].substring(0,10) + ".."
                else
                  var user = row[11]
              return "<div style='min-width:130px'><span title='"+row[11]+"' class='project_job_ass_"+row[1]+"'>"+user+"</span><span class='dropdown'><span class='caret dropdown-toggle space-left black' style='cursor:pointer'  data-toggle='dropdown' onclick='get_assigned_user(\""+row[1]+"\")'></span><ul class='dropdown-menu' style='left: -8px;'><li class='arrow_top'></li><div class='assigned_user_list'><img  src='/assets/ajax-loader2.gif'/></div></ul><span></div>"
            }else{
              return ""
            }
          }
        },
        {
          aTargets: [6],
          bSortable: false,
          mRender: function (data, type, row ) {
           if(row[6] != ''){
              if(row[6].length > 12)
                  var user = row[6].substring(0,10) + ".."
                else
                  var user = row[6]
              return "<div style='min-width: 100px;'><span class='project_job_pri_col "+row[6]+" job_pri_"+row[1]+"'></span><span title='"+row[6]+"' class='project_job_pri_"+row[1]+"'>"+user+"</span><span class='dropdown'><span class='caret dropdown-toggle space-left black' style='cursor:pointer'  data-toggle='dropdown'></span><ul class='dropdown-menu pri_optn' style='left: -8px;min-width: 100px;'><li class='arrow_top' style='top:-11px;'></li><li style='cursor:pointer;padding:0 10px' onclick='change_priority(\""+row[1]+"\", \"High\")'>High</li><li style='cursor:pointer;padding:0 10px' onclick='change_priority(\""+row[1]+"\", \"Medium\")'>Medium</li><li style='cursor:pointer;padding:0 10px' onclick='change_priority(\""+row[1]+"\", \"Low\")'>Low</li></ul><span></div>"
            }else{
              return ""
            }
          }
        },
        {
          aTargets: [7],
          bSortable: true,
          mRender: function (data, type, row ) {
           return row[7]
          }
        },
        {
          aTargets: [8],
          bSortable: false,
          mRender: function (data, type, row ) {
            var cls = row[8].replace(" ", "_").toLowerCase();
            if(row[8].length > 11){
              var status_txt = row[8].substring(0, 9) + ".."
              var status_title = row[8]
            }else{
              var status_txt = row[8];
              var status_title = ""
            }
            return "<span class='project_status project_job_"+row[1]+" background_"+cls+"' title='"+status_title+"'>"+status_txt+"</span><span class='dropdown'><span class='caret dropdown-toggle space-left black' style='cursor:pointer'  data-toggle='dropdown'></span><ul class='dropdown-menu pri_optn' style='left: -8px;min-width: 115px;text-align: left;'><li class='arrow_top' style='top:-11px;'></li><li style='cursor:pointer;padding:0 10px' onclick='change_status(\""+row[1]+"\", \"New\")'>New</li><li style='cursor:pointer;padding:0 10px' onclick='change_status(\""+row[1]+"\", \"In Progress\")'>In Progress</li><li style='cursor:pointer;padding:0 10px' onclick='change_status(\""+row[1]+"\", \"Resolved\")'>Resolved</li><li style='cursor:pointer;padding:0 10px' onclick='change_status(\""+row[1]+"\", \"Blocked\")'>Blocked</li><li style='cursor:pointer;padding:0 10px' onclick='change_status(\""+row[1]+"\", \"Closed\")'>Closed</li></ul><span>"
          }
        },
        {
          aTargets: [9],
          bSortable: false,
          mRender: function (data, type, row ) {
            var dt = new Date(row[9]);
            console.log(dt)
            console.log(row[9])
            var today = new Date();
            var diff = new Date(dt - today);
            var days = diff/1000/60/60/24;
            console.log(diff)
            console.log(days)
            var due_class = 'text-success'
            days = Math.round(days)
            if(days == 1 )
            {
              type = 'Tomorrow'
            }
            else if(days == 0 )
            {
              type = 'Today'
              due_class = 'text-success'
            }
            else if ( days > 1)
            {
              type = dt.toString("MMM d, ddd")
            }
            else if( days == -1)
            {
              type = 'Yesterday'
              due_class = 'text-warning'
            }
            else if (days  < -1)
            {
              type = "Overdue"
              type += "<br><span class='small'> by " + Math.abs(days).toString() + " days</span>"
              due_class = 'text-danger font-bold'
            }
            else
            {
              type = row[18]
            }
           
           return "<div><span class='display_due_date " + due_class +"' id='" + row[1] + "' value='"+row[9]+"'>"+type+"</span><span class='date_picker_due_date due_date_for_job_list_"+row[1]+" caret' style='cursor:pointer;' onclick=\"set_due_date_in_datepicker('"+row[18]+"')\"></span></div>"
          }
        },
      ],
      fnPreDrawCallback: function() { $('#task_loader,.fixed_loader').show(); },
      "fnDrawCallback": function ( oSettings ) {
        $(function () {
          $('#task_loader,.fixed_loader').hide(); 
          //var job_type = "#{params[:job_status]}";
          var job_type = r_job_status;
          var set_date = $(this).prev(".display_due_date").val();
          // $('.date_picker_due_date').datetimepicker();
          $('.date_picker_due_date').datetimepicker({useCurrent: false,  format: 'MM-DD-YYYY'}).on('dp.change', function(e){
            var d = new Date(e.date);
            var m = parseInt(d.getMonth()) + 1;
            var dt = d.getDate()+"-"+ m +"-"+d.getFullYear();
            var date_span = $(this).prev(".display_due_date");
            var project_job_id = date_span.attr("id");
            $("#task_loader,.fixed_loader").show();
            $.ajax({
              url: "/update_due_date?project_job_id=" + project_job_id,
              data: {date: dt, page: "job_listing"},
              success: function(data){ 
                $("#task_loader,.fixed_loader").hide();
                date_span.text(data);
                $(".bootstrap-datetimepicker-widget").hide();
              },
              error: function(data){
                $("#task_loader,.fixed_loader").hide();
                alert('Got an error while updating due date');
              }
            });

          });
        });
        if ( oSettings.aiDisplay.length == 0 )
        {
          return;
        }

        var nTrs = $('#projectJobDataTable tbody tr');
        var iColspan = nTrs[0].getElementsByTagName('td').length;
        var sLastGroup = "";
        // if(oSettings.aoData[oSettings.aiDisplay[iDisplayIndex]] == 'undefined'){
        //   return
        // }
        for ( var i=0 ; i<nTrs.length ; i++ )
        {
            var iDisplayIndex = oSettings._iDisplayStart + i;
            var sGroup = oSettings.aoData[oSettings.aiDisplay[iDisplayIndex]]._aData[12];
            if ( sGroup != sLastGroup )
            {
                var nGroup = document.createElement( 'tr' );
                var nCell = document.createElement( 'td' );
                nCell.colSpan = iColspan;
                nCell.className = "group";
                nCell.innerHTML = sGroup;
                nGroup.appendChild( nCell );
                nTrs[i].parentNode.insertBefore( nGroup, nTrs[i] );
                sLastGroup = sGroup;
            }
        }
      }
    });
  initializeProjectJobsActions()
}


  
  function change_priority(project_job_id, priority){
    $("#task_loader,.fixed_loader").show();
    $.ajax({
      url: "/change_priority_for_project_job",
      data: {project_job_id: project_job_id, priority: priority},
      success: function(data){ 
        if(data.length > 12){
          name = data.substring(0,10) + ".."
        }else{
          name = data
        }
        $(".project_job_pri_"+project_job_id).html(name);
        $(".project_job_pri_col_"+priority.toLowerCase()).html(name);
        $(".job_pri_"+project_job_id).removeClass("High").removeClass("Medium").removeClass("Low");
        $(".job_pri_"+project_job_id).addClass(priority);
        $("#task_loader,.fixed_loader").hide();
      },
      error: function(data){
        $("#task_loader,.fixed_loader").hide();
        alert('Got an error while changing priority.');
      }
    });
  }
  function change_status(project_job_id, status){
    $("#task_loader,.fixed_loader").show();
    $.ajax({
      url: "/change_status_in_job_details",
      data: {project_job_id: project_job_id, status: status, page: "index"},
      success: function(data){
        var cls = "background_"+data.replace(" ", "_").toLowerCase()
        if(data.length > 11){
          var status = data.substring(0,9) + ".."
          var place_txt = data
        }else{
          var status = data
          var place_txt = ""
        }
        $(".project_job_"+project_job_id).text(status).removeClass("background_catch-up_later background_resolved background_in_progress background_closed background_new").addClass(cls).removeAttr("title").prop("title",place_txt)
        $(".right_sec").load(location.href + " .right_sec");
        setTimeout(function() 
        {
          $("#task_loader,.fixed_loader").hide();
        }, 2000);        

      },
      error: function(data){
        $("#task_loader,.fixed_loader").hide();
        alert('Got an error while changing status.');
      }
    });
  }
  function set_job_id(){

  }
  function set_due_date_in_datepicker(dt){
    //var due_date = Date(dt);
    //alert(dt);
    //alert(due_date);
    //$(this).datetimepicker({
    //  'setDate':due_date
    //});
  }


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
      $("#select_all_jobs").prop("checked",true);
    }else{
      $("#select_all_jobs").prop("checked",false);
    }
    var $cbs = $('input[name="job_check_box"]');
    var total = 0;
    $cbs.each(function() {
      if (this.checked){
          total ++;
      }
    });
    if(total > 0){
      $("#jobtListingLabel").removeClass("label_arrow").addClass("label_arrow_active");
      $("#jobListing_Dropdown").attr("data-toggle", "dropdown")
    }else{
      $("#jobtListingLabel").removeClass("label_arrow_active").addClass("label_arrow");
      $("#jobListing_Dropdown").removeAttr("data-toggle", "dropdown");
      $(".DataTables_sort_wrapper").removeClass("open")
    }
  var checkboxes = document.getElementsByName('job_check_box');
  var vals = "";
  for (var i=0, n=checkboxes.length;i<n;i++) {
   if (checkboxes[i].checked) 
   {
    vals += checkboxes[i].value+ ","
   }
  }
  $("#resolve_job_ids").val(vals);
  $("#close_job_ids").val(vals);
  };

  function display_project_jobs(job_status,id=""){

    var project_id = $("#project_id").val();
    //if(id==""){
    //  window.history.pushState(null, "Title", "/projects/#{params[:project_id]}/jobs?type="+job_status+"");
    //}else{
    window.history.pushState(null, "Title", "/projects/" + project_id + "/jobs?type="+job_status);
    //}
    $("#job_status_value").val(job_status);
    $("#job_type").val(job_status);
    document.cookie="status="+job_status;
    $.ajax({
        type: "POST",
        url: "/jobs_list",
        dataType: 'json',
        data: {job_status: job_status, project_id: project_id},
        async: true,
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
          //alert(data.responseText)
          $("#jobs_list").html(data.responseText);
          $("#task_loader,.fixed_loader").hide();
          $("li").removeClass("active");
          $("#"+job_status+"Job").addClass("active");
          multi_filter_project_jobs(job_status);
          $(".display_job_type").html(job_status);
        }
    });
  }

  function display_calendar_view(){
    var project_id = $("#project_id").val();
    //window.history.pushState(null, "Title", "/projects/" + project_id + "/jobs?calendar_view=true");
    $.ajax({
        type: "POST",
        url: "/calendar_view",
        dataType: 'json',
        data: {project_id: project_id},
        async: true,
        beforeSend: function(){
          $("#task_loader,.fixed_loader").show();
          $(".tasks-tabs, .project_job_top_sec").hide();
        },
        success: function(data)
        {
         
        },
        error: function(data) {
          $("#task_loader,.fixed_loader").hide();
        },
        complete: function(data) {
          $("#jobs_list").html(data.responseText);
          $("#task_loader,.fixed_loader").hide();
          $(".active_job_group_icon").removeClass("active_job_group_icon cwkp-sprite").html("<a title='Group by type' href='/projects/"+$("#project_id").val()+"/jobs?by_group_name=true'><span class='cwkp-sprite new_comp_size_icon'></span></a>");
          $(".active_list_view_icon").removeClass("active_list_view_icon cwkp-sprite").html("<a title='List View' href='/projects/"+$("#project_id").val()+"/jobs'><span class='cwkp-sprite new_list_view_icon'></span></a>")
          $(".new_filter_icon").hide();
          $("#calendar_view").html("<span title='Calendar View' class='cwkp-sprite active_job_calendar_icon'></span>");
        }
    });
  }


  function add_css(type){
    $("#"+type+"Job").addClass('active').attr('style', 'border-radius:4px 0 0 4px;outline:none');
  }

  function get_assigned_user(project_job_id){
    $.ajax({
      url: "/get_user_list_for_project_job",
      data: {project_job_id: project_job_id},
      success: function(data){ 
        $(".assigned_user_list").html(data);
      },
      error: function(data){
        alert('Got an error while getting user list.');
      }
    });
  }

  function fetch_project_jobs(id){
    
    var cuser = cuser;
    $("#task_loader,.fixed_loader").show();
    $.ajax({
      type: 'GET',
      url: "/projects/" + id +"/jobs",
      dataType: 'json',
      data: {cuser: cuser},
      async: true,
      complete: function(data){ 
        window.history.pushState(null, "Title", "/projects/" + id + "/jobs");
        display_project_jobs("all",id);
        $(".top-task-bar").load(location.href + " .top-task-bar");
        $(".project_job_top_sec").load(location.href + " .project_job_top_sec");
        $("#task_loader,.fixed_loader").hide();
      }
    });
  }


  function display_project_jobs_hide_submenu(type)
  {
    if(type == "created")
    {
      reser_all_project_jobs_submenu();
      $('.cre_arw').show();
      $('#cr').show();

    }
    else if(type == "assigned")
    {
      reser_all_project_jobs_submenu();
      $('.asg_arw').show();
      $('#asg').show();
    }
    else if(type == "priority")
    {
      reser_all_project_jobs_submenu();
      $('.pri_arw').show();
      $('#pr').show();
    }
    else if(type == "status")
    {
      reser_all_project_jobs_submenu();
      $('.sta_arw').show();
      $('#st').show();
    }    
    else if(type == "anytime")
    {
      reser_all_project_jobs_submenu();
      $('.any_arw').show();
      $('#any').show();
    }
    else if(type == "last")
    {
      reser_all_project_jobs_submenu();
      $('.lst_arw').show();
      $('#lat').show();
    }
   else if(type == "proj")
    {
      reser_all_project_jobs_submenu();
      $('.proj_arw').show();
      $('#proj').show();
    }
  }
  function reser_all_project_jobs_submenu()
  {
   $('.cre_arw').hide();
   $('#cr').hide();
   $('.asg_arw').hide();
   $('#asg').hide();
   $('.any_arw').hide();
   $('#any').hide();
   $('.proj_arw').hide();
   $('#proj').hide();
   $('.pri_arw').hide();
   $('#pr').hide();
   $('.sta_arw').hide();
   $('#st').hide();
  }
  function chk_radio_button_jobs(id, type, inputNode){
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
    else if(type == "priority")
    {
     $("input:checkbox[name='prio']:checked").each(function() {
       var values = $(this).val();
       $("#priority_"+values).attr("checked", true);
     });
    }
    else if(type == "status")
    {
     $("input:checkbox[name='stat']:checked").each(function() {
       var values = $(this).val();
       $("#status_"+values).attr("checked", true);
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
    else if(type == "proj")
    {
     $("input:checkbox[name='proj']:checked").each(function() {
       var values = $(this).val();
       $("#proj_"+values).attr("checked", true);
     });
    }
    else if(type == "proj_stage")
    {
     $("input:checkbox[name='proj_stage']:checked").each(function() {
       var values = $(this).val();
       $("#proj_stage_"+values).attr("checked", true);
     });
    }
    multi_filter_project_jobs();
  }

  function multi_filter_project_jobs(tab) {
    
    var page_tab = tab;
    var cre_by_val = "";
    var proj_val = "";
    var asg_by_val = "";
    var proj_val = "";
    var priority_val = "";
    var status_val = "";
    var proj_stage_val = "";
    $("input:checkbox[name='created_by']:checked").each(function(i) {
      var values = $(this).val() + "|";
      cre_by_val += values;
    });    
    $("input:checkbox[name='assg_by']:checked").each(function(i) {
      var assg_vals = $(this).val() + "|";
      asg_by_val += assg_vals;
    });
    $("input:checkbox[name='proj']:checked").each(function(i) {
      var values = $(this).val() + "|";
      proj_val += values;
    });
    $("input:checkbox[name='prio']:checked").each(function(i) {
      var pri_val = $(this).val() + "|";
      priority_val += pri_val;
    });
    $("input:checkbox[name='stat']:checked").each(function(i) {
      var sta_val = $(this).val() + "|";
      status_val += sta_val;
    }); 
    $("input:checkbox[name='proj_stage']:checked").each(function(i) {
      var prj_stage_val = $(this).val() + "|";
      proj_stage_val += prj_stage_val;
    }); 
    if(page_tab==""){
      document.cookie="page_tab=all";
    }else{
      document.cookie="page_tab="+page_tab;
    }
    var dt_range = $("input:radio[name='anytime']:checked").val();
    var last_touch = $("input:radio[name='last_touch']:checked").val();
    var dt_range_from = $("#project_from").val();
    var dt_range_to = $("#project_to").val();
    if(dt_range == "Custom Date")
      $("#custom_date").show();
    else
      $("#custom_date").hide();

    if("#{params[:by_group_name].present?}"=="true"){
      var by_group_name = "true";
    }else{
      var by_group_name = "false";
    }
    var posturl= "/jobs_list";
    divid= "jobs_list";
    $("#filter_get_val").val(1);
    var project_id = $("#project_id").val();
    var cre_by = false;
    var asg_by = false;
    var proj = false;
    var priority = false;
    var status = false;
    var daterange = false;
    var dtrange_from = false;
    var dtrange_to = false;
    var proj_stage = false;
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
    if(proj_val != "" && typeof proj_val != 'undefined'){

      proj = true;
      var proj_txt = "";
      $("input:checkbox[name='proj']:checked").each(function() {
        proj_txt += $('#proj_'+$(this).val()).attr("a_name") + '|';
      });
      proj_txt = proj_txt.slice(0,-1);
      document.cookie="proj=true";
      document.cookie="proj_val="+proj_val;
      document.cookie="proj_txt="+proj_txt;
      $(".tag_filter").show();
      $(".proj_tag").show();
      $("#proj_tag_txt").html(proj_txt.split('|').join(','))
    }
    if(proj_val == "" || typeof proj_val === 'undefined'){

     $(".proj_tag").hide();
     $.removeCookie("proj");
     $.removeCookie("proj_val");
     $.removeCookie("proj_txt");
    }
    // project stage
    if(proj_stage_val != "" && typeof proj_stage_val != 'undefined'){

      proj_stage = true;
      var proj_stage_txt = "";
      $("input:checkbox[name='proj_stage']:checked").each(function() {
        proj_stage_txt += $('#proj_stage_'+$(this).val()).attr("a_name") + '|';
      });
      proj_stage_txt = proj_stage_txt.slice(0,-1);
      document.cookie="proj_stage=true";
      document.cookie="proj_stage_val="+proj_stage_val;
      document.cookie="proj_stage_txt="+proj_stage_txt;
      $(".tag_filter").show();
      $(".proj_stage_tag").show();
      $("#proj_stage_tag_txt").html(proj_stage_txt.split('|').join(','))
    }
    if(proj_stage_val == "" || typeof proj_stage_val === 'undefined'){

     $(".proj_stage_tag").hide();
     $.removeCookie("proj_stage");
     $.removeCookie("proj_stage_val");
     $.removeCookie("proj_stage_txt");
    }
    ////////////
    if(priority_val != "" && typeof priority_val != 'undefined'){

      priority = true;

      var priority_txt = "";
      $("input:checkbox[name='prio']:checked").each(function() {
        priority_txt += $('#priority_'+$(this).val()).attr("prio_name") + '|';
      });
      priority_txt = priority_txt.slice(0,-1);
      document.cookie="priority=true";
      document.cookie="priority_val="+priority_val;
      document.cookie="priority_txt="+priority_txt;
      $(".tag_filter").show();
      $(".priority_tag").show();
      $("#priority_tag_txt").html(priority_txt.split('|').join(','));
    }
    if(priority_val == "" || typeof priority_val === 'undefined'){

      $(".priority_tag").hide();
      $.removeCookie("priority");
      $.removeCookie("priority_val");
      $.removeCookie("priority_txt");
    }

    if(status_val != "" && typeof status_val != 'undefined'){

      status = true;

      var status_txt = "";

      $("input:checkbox[name='stat']:checked").each(function() {
        status_txt += $('#status_'+$(this).val().replace(' ','_')).attr("stat_name") + '|';
      });
      
      status_txt = status_txt.slice(0,-1);
      document.cookie="status=true";
      document.cookie="status_val="+status_val;
      document.cookie="status_txt="+status_txt;
      $(".tag_filter").show();
      $(".status_tag").show();
      $("#status_tag_txt").html(status_txt.split('|').join(','));
    }
    if(status_val == "" || typeof status_val === 'undefined'){

      $(".status_tag").hide();
      $.removeCookie("status");
      $.removeCookie("status_val");
      $.removeCookie("status_txt");
    }

    if(priority_val == "" && status_val == "" && cre_by_val == "" && proj_val == "" && proj_stage_val == "" && asg_by_val == "" && proj_val != 1 && (typeof last_touch === 'undefined') && dt_range_from == "" && dt_range_to == "" && ((dt_range == "" || typeof dt_range === 'undefined') && dt_range != "Custom Date")){
      $('.reset_tag').hide();
      $(".tag_filter").hide();
    }
    else if(dt_range == "Custom Date" &&(dt_range_from == "" && dt_range_to == ""))
    {
     $('.reset_tag').hide();
    }
    else if(typeof priority_val === 'undefined' && typeof status_val === 'undefined' && typeof cre_by_val === 'undefined' && typeof proj_val === 'undefined' && typeof proj_stage_val === 'undefined' && typeof asg_by_val === 'undefined' && typeof dt_range === 'undefined' && (typeof dt_range_from === 'undefined' || dt_range_from == "") && (typeof dt_range_to === 'undefined' || dt_range_to == ""))
    {
      $('.reset_tag').hide();
    }
    else{
      $('.reset_tag').show();
      $(".tag_dd").show();
    }
    if((typeof priority_val != "undefined" || priority_val != "") || (typeof status_val != "undefined" || status_val != "") || (typeof proj_val != "undefined" || proj_val != "") || (typeof proj_stage_val != "undefined" || proj_stage_val != "")|| (typeof cre_by_val != "undefined" || cre_by_val != "") || (typeof asg_by_val != "undefined" || asg_by_val != "") || (typeof dt_range != 'undefined' && dt_range != "Custom Date"))
    {
      $.ajax( {
        type: "POST",
        url: posturl ,
        data: {project_id: project_id, cre_by: cre_by, cre_by_val: cre_by_val, proj: proj, proj_val: proj_val, asg_by: asg_by, asg_by_val: asg_by_val, daterange: daterange, dt_range: dt_range, dtrange_from: dtrange_from,dt_range_from: dt_range_from,dtrange_to: dtrange_to,dt_range_to: dt_range_to, priority: priority, priority_val: priority_val, status: status, status_val: status_val, page_tab: page_tab, by_group_name: by_group_name, proj_stage: proj_stage, proj_stage_val: proj_stage_val},
        beforeSend: function(){
          $("#task_loader,.fixed_loader").show();
        },
        success: function(result) {
          //$(".nav.nav-tabs").find("li").removeClass("active");
          //$(".tag_filter").show();
          //$("#all_tab").removeClass("active");
          $("#"+divid).html("");
          $("#"+divid).html(result);
          $("#task_loader,.fixed_loader").hide();
        },
        error: function(result){
          $("#task_loader,.fixed_loader").hide();
        }
      });
     }
    else if(dt_range_from != "" && dt_range_to != "")
    {
       $.ajax( {
        type: "POST",
        url: posturl ,
        data: {cre_by: cre_by, cre_by_val: cre_by_val, asg_by: asg_by, asg_by_val: asg_by_val, daterange: daterange, dt_range: dt_range, last_touch: last_touch, dtrange_from: dtrange_from,dt_range_from: dt_range_from,dtrange_to: dtrange_to,dt_range_to: dt_range_to},
        success: function(result) {
          $("#"+divid).html("");
          $("#"+divid).html(result);
        },
        error: function(result){
          $("#task_loader,.fixed_loader").hide();
        }
      });
    }
    else if(cre_by_val == "" && asg_by_val == "" && loc_val == "" && dt_range == "" && (dt_range_from == "" || dt_range_to == ""))
    {
       $.ajax( {
        type: "POST",
        url: posturl ,
        data: {cre_by: cre_by, cre_by_val: cre_by_val, asg_by: asg_by, asg_by_val: asg_by_val, daterange: daterange, dt_range: dt_range, dtrange_from: dtrange_from,dt_range_from: dt_range_from,dtrange_to: dtrange_to,dt_range_to: dt_range_to},
        beforeSend: function(){
          $("#task_loader,.fixed_loader").show();
        },
        success: function(result) {
          $("#"+divid).html("");
          $("#"+divid).html(result);
          $("#task_loader,.fixed_loader").hide();
        },
        error: function(result){
          $("#task_loader,.fixed_loader").hide();
        }
      });

    }
    else if(typeof cre_by_val === 'undefined' && typeof asg_by_val === 'undefined' && typeof dt_range === 'undefined' && (dt_range_from == "" || dt_range_to == ""))
    {
       $.ajax( {
        type: "POST",
        url: posturl ,
        data: {cre_by: cre_by, cre_by_val: cre_by_val, asg_by: asg_by, asg_by_val: asg_by_val, daterange: daterange, dt_range: dt_range, dtrange_from: dtrange_from,dt_range_from: dt_range_from,dtrange_to: dtrange_to,dt_range_to: dt_range_to},
        beforeSend: function(){
          $("#task_loader,.fixed_loader").show();
        },
        success: function(result) {
          $("#"+divid).html("");
          $("#"+divid).html(result);
          $("#task_loader,.fixed_loader").hide();
        },
        error: function(result){
          $("#task_loader,.fixed_loader").hide();
        }
      });
    }
  }
  function reset_filter_jobs(id,class_n,stage_f){
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

    if(id == "proj"){
      $("#proj").val(0);
      $('.proj_tag').hide();
      $.removeCookie("proj");
    }
    if(id == "proj_stage"){
      $("#proj_stage").val(0);
      $('.proj_stage_tag').hide();
      $.removeCookie("proj");
    }
    multi_filter_project_jobs();
    $("#task_loader,.fixed_loader").hide();
  }
  function reset_filter_val_jobs(){
    $("#filter_get_val").val(0);
  }
  function reset_all_filter_jobs(){
    $("#filter_get_val").val(0);
    $('.label_tag').hide();
    $('.created_by_tag').hide();
    $('.assigned_to_tag').hide();    
    $('.priority_tag').hide();
    $('.status_tag').hide();
    $('.reset_tag').hide();
    $('.tag_filter').hide();
    $('.cre_by_c').removeAttr('checked');
    $('.proj').removeAttr('checked');
    $('.asg_by_c').removeAttr('checked');
    $('.any_time').removeAttr('checked');
    $('.lst_tch').removeAttr('checked');
    $('.priority_c').removeAttr('checked');
    $('.status_c').removeAttr('checked');

    $('#project_from').val('');
    $('#project_to').val('');
    $("#proj").val(0);
    $.each(["cre_by","cre_by_val","cre_by_txt", "proj","proj_val","proj_txt","daterange","dt_range","dt_range_txt","asg_by","asg_by_val","priority","priority_val","status","status_val","asg_by_txt","dtrange_from","dt_range_from","dt_range_frm_txt","dtrange_to","dt_range_to","dt_range_to_txt","page_tab","proj_stage","proj_stage_val","proj_stage_txt"], function( index, value ) {
       $.removeCookie(value);
    });
    multi_filter_project_jobs();
  }
  // function showStatusAfterJobCreate(status,msg){
  //   if(status == "success")
  //   {
  //     show_alert_message("success",msg);
  //     $('#projectJobModal').modal('hide');
      
  //     show_kanban_view();
  //   }
  //   if(status == "error")
  //   {
  //     show_alert_message("error",msg);
  //   }
  // }
  function showStatusAfterJobCreate(status,msg,project_id, load_project_id){
    
    if(status == "success")
    {
      $('#projectJobModal').modal('hide');
      $("#scheduleModal").modal('hide');
      $('.modal-backdrop').remove();
      if($("#filter_by_project_user").length){
        show_kanban_view();
      }else{
        get_jobs_kanban_view(load_project_id);
      }
      show_alert_message("success",msg);
      var jobs_str = $('#project_' + load_project_id).find(".jobs_count").html().trim()
      console.log(jobs_str)
      var jobs_count = parseInt(jobs_str);
      
      $('#project_' + load_project_id.toString()).find(".jobs_count").html((jobs_count+ 1).toString()) ;
      
    }
    if(status == "error")
    {
      show_alert_message("error",msg);
    }
  }