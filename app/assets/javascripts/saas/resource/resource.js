var oTableResource = null;
function fillResourceUtilizationData(){
	oTableResource = $('#dataTableResourceUtilization').dataTable({
      oLanguage: {"sLengthMenu": "_MENU_" },
      sPaginationType: "bootstrap",
      bJQueryUI: true,
      bServerSide: true,
      aoColumns: [{sWidth: 'col-md-1'}, {sClass: 'col-md-2'}, {sClass: 'col-md-2'},{sClass: 'col-md-2'}, {sClass: 'col-md-1'},{sClass: 'col-md-1'}, {sClass: 'center-align col-md-1'},{sClass: 'col-md-1'}],
      "sDom": '<"dtTop dtTables">rt<"dtBottom"><"dtInfo fl"i><"dtPagination fr"p>',
      sAjaxSource: $('#dataTableResourceUtilization').data('source'),
      bLengthChange: false,
      oLanguage: { 
        "sSearch": "" ,
        oPaginate: {
          sPrevious: "Prev"
        }
      },
      aaSorting: [[0,'desc']],
      aoColumnDefs: [
        {
          aTargets: [0],
          bSortable: true,
         },
        {
          aTargets: [1],
          bSortable: false,
          bSearchable: true,
        },
        {
          aTargets: [2],
          bSortable: false,
        },
        {
          aTargets: [3],
          bSortable: true,
          bSearchable: true,
        },
        {
          aTargets: [4],
          bSortable: true,
          bSearchable: true,
        },
        {
          aTargets: [5],
          bSortable: true,
        },
        {
          aTargets: [6],
          bSortable: true,
        },
        {
          aTargets: [7],
          bSortable: true,
        },
        
      ],
      fnPreDrawCallback: function() { 
      $("#dataTableResourceUtilization_filter input").attr("placeholder", "Search...");
      $('#task_loader,.fixed_loader').show();},
      fnDrawCallback: function() {
        $('#task_loader,.fixed_loader').hide();
        //$(".org_count").html(organizationDataTable.fnSettings().fnRecordsDisplay());
        //$('span').powerTip({smartPlacement: true,fadeInTime: 100,fadeOutTime: 200});

      },
    });   
    $('#myInputTextField').keyup(debounce(350, this,fillResourceUtilization ));
    
}
function get_resource_allocation_user(user_id,type="default"){
    var id = id;
    var type = type;
    var start_date = $("#project_job_start_date").val();
    var end_date = $("#project_job_due_date").val();
    
    $.ajax({
      url: '/get_resource_allocation',
        type: 'GET',
        data: {user_id: user_id, start_date: start_date,end_date:end_date,view_for:type},
        dataType: 'json',
        async: true,
        beforeSend: function(){
          $("#task_loader,.fixed_loader").show();
        },
        complete: function(data) {

          $(".resource-allocated-hours").html(data.responseText);
          $("#task_loader,.fixed_loader").hide();
        }
    });
  }
  function get_resource_allocation(view_for = 'current',project_id=0){
    var allot_type =  $('input:radio[name="allot_type"]:checked').val();
    var start_date = $("#res_start_dt").val();
    var end_date = $("#res_end_dt").val();
    var view_for = view_for;
    project_id = project_id == 0 ? $("#resource_project_id").val() : project_id
    $.ajax({
      url: '/get_resource_allocation',
        type: 'GET',
        data: {allot_type: allot_type, view_for: view_for,start_date: start_date,end_date: end_date,project_id: project_id},
        dataType: 'json',
        async: true,
        beforeSend: function(){
          $("#task_loader,.fixed_loader").show();
        },
        complete: function(data) {
          //alert(data.responseText)
          $(".div_resource_allocation").html(data.responseText);
          $("#task_loader,.fixed_loader").hide();
          $(".modal-backdrop").remove();

        }
    });
  }
  function get_weekly_timesheet(view_for = 'current'){
    var start_date = $("#res_start_dt").val();
    var end_date = $("#res_end_dt").val();
    var view_for = view_for;
    var user_id = $("#resource_id").val()
    $.ajax({
      url: '/get_weekly_timesheet',
        type: 'GET',
        data: {view_for: view_for,start_date: start_date,end_date: end_date,user_id: user_id},
        dataType: 'json',
        async: true,
        beforeSend: function(){
          $("#task_loader,.fixed_loader").show();
        },
        complete: function(data) {
          //alert(data.responseText)
          $(".div_weekly_timesheet").html(data.responseText);
          $("#task_loader,.fixed_loader").hide();

        }
    });
  }
  function getResourceUtilization(){
    var sSearch= $('#myInputTextField').val();
    var project_id = $("#utilization_project_id").val();
    var user_id = $("#utilization_user_id").val();
    var to_log_date = $("#to_log_date").val()
    var from_log_date = $("#from_log_date").val()
    $.ajax({
        type: "POST",
        url: "/get_resource_utilization" ,
        dataType:"html",
        data: {project_id:project_id,user_id: user_id,from_log_date: from_log_date,to_log_date: to_log_date,sSearch: sSearch},
        success: function(result) {
        
          $(".resources-list").html("").html(result)
          //fillResourceUtilizationData()
          //oTableResource.fnDraw()
        }
    })
  }
  
  function get_reallocate_resource(project_job_id,type,user_id)
  {
    
    $.ajax({
      url: '/get_resource_for_reallocation',
        type: 'GET',
        data: {user_id: user_id,view_for:type,project_job_id:project_job_id},
        dataType: 'json',
        async: true,
        beforeSend: function(){
          $("#task_loader,.fixed_loader").show();
        },
        complete: function(data) {
          //alert(data.responseText)
          $("#reallocate-resource-div").html(data.responseText);
          $("#task_loader,.fixed_loader").hide();
        }
    });
  }
  function calculate_total_spenthours(){
    var hours=0;
    var minutes = 0
    $.each($("input.resource-allot-hours"), function(key, input ) {
      var input_value = $(input).val();
      console.log(input_value)
      if(input_value != "" && input_value != "0" && input_value.indexOf("_") < 0)
      {
        hours = hours + parseInt(input_value.split(":")[0])
        minutes = minutes + parseInt(input_value.split(":")[1])
      }
    });
    hours = hours + parseInt(minutes / 60);
    minutes = minutes % 60;
    var calc_value = (hours < 10 ? "0" : "") + hours.toString() + ":" +   (minutes < 10 ? "0" : "") + minutes.toString()
    //var estimate_in_min = parseFloat($("#project_job_estimate_hour").val()) * 60
    var estimate_in_min = parseFloat($("#project_job_estimate_minutes").val())
    var spent_time_min = $("#project_job_spent_time").val()

    if ((hours * 60 + minutes) != estimate_in_min ) 
    {
      $("#estimation_match").html("Allotted time did not match with estimation")
      $("#estimation_match").addClass("alert-danger")
      $("#estimation_match").removeClass("alert-success")
      $("#reallocate-submit-btn").attr("disabled", "disabled");
    }
    else
    {
      $("#estimation_match").html("Allotted time matched with estimated hours")
      $("#estimation_match").addClass("alert-success")
      $("#estimation_match").removeClass("alert-danger")
      $("#reallocate-submit-btn").removeAttr("disabled");
    }
   
    $("#total_spent_hours").val(calc_value)
  }
  function clear_distribution_fields()
  {
    $("form#form_reallocate_resource").find(':text:not("[readonly]")').val('');
    calculate_total_spenthours()
    return false;
  }
