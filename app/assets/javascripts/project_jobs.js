function change_status_in_job_details(project_job_id, status){
    $("#task_loader,.fixed_loader").show();
    $.ajax({
      url: "/change_status_in_job_details",
      data: {project_job_id: project_job_id, status: status},
      success: function(data){ 
        // $(".project_job_status").html(data);
        // $(".container").load(location.href + ".container");
        // initialize_tinymce();

        if(window.location.href.indexOf("kanban") > -1)
        {
        show_kanban_view();
        }
        changeJobStatusDetails(project_job_id)
        fetch_job_content(project_job_id,'refresh');
        $("#task_loader,.fixed_loader").hide();
      },
      error: function(data){
        $("#task_loader,.fixed_loader").hide();
        alert('Got an error while changing status.');
      }
    });
  }
  function update_job_status(project_job_id, status){
    $("#task_loader,.fixed_loader").show();
    $.ajax({
      url: "/update_job_status",
      data: {project_job_id: project_job_id, status: status},
      success: function(data){ 
         show_alert_message("success", data);
         $("#task_loader,.fixed_loader").hide();
      },
      error: function(data){
        $("#task_loader,.fixed_loader").hide();
        alert('Got an error while changing status.');
      }
    });
  }
  
  function changeJobStatusDetails(id, status = null){
      $("#task_loader, .fixed_loader").show();
      $.ajax({
        url: "/change_job_status_from_details",
        data: {id: id,status: status},
        success: function(data){ 
          $(".opp_status_bar_sec").html(data);
          fetch_job_content(id,'refresh');
          $("#task_loader, .fixed_loader").hide();
        },
        error: function(data){
          $("#task_loader, .fixed_loader").hide();
        }
      });
    }
  function fetch_job_content(id,type){
    var id = id;
    var type = type;
    $.ajax({
      url: '/fetch_job_content',
        type: 'GET',
        data: {id: id, type: type},
        dataType: 'json',
        async: true,
        beforeSend: function(){
          $("#task_loader,.fixed_loader").show();
        },
        complete: function(data) {
          //alert(data.responseText)
          $(".job_detail_page").html(data.responseText);
          initialize_tinymce();
          
          $("#task_loader,.fixed_loader").hide();
          if (typeof(Dropzone) ===  undefined)
            {Dropzone.discover();}

        }
    });
  }
  function initialize_tinymce(){
    // $('#comment_comment').wysiwyg({
    //   rmUnusedControls: true,
    //   controls: {
    //     bold: { visible : true },
    //     underline: { visible: true },
    //     italic: { visible: true },
    //     insertOrderedList: { visible: true },
    //     insertUnorderedList: { visible: true },
    //     undo: { visible: true },
    //     redo: { visible: true },
    //     indent: { visible: true },
    //     outdent: { visible: true },
    //     removeFormat: { visible: true },
    //     increaseFontSize: { visible: true },
    //     decreaseFontSize: { visible: true }
    //   }
    // });
    $('#comment_comment').summernote({
      toolbar: [
          ['headline', ['style']],
          ['style', ['bold', 'italic', 'underline', 'superscript', 'subscript', 'strikethrough', 'clear']],
          ['textsize', ['fontsize']],
          ['alignment', ['ul', 'ol', 'paragraph', 'lineheight']],
      ]
    });
  }
    function initialize_tinymce_timelog(){
    // $('#job_time_log_note').wysiwyg({
    //   rmUnusedControls: true,
    //   controls: {
    //     bold: { visible : true },
    //     underline: { visible: true },
    //     italic: { visible: true },
    //     insertOrderedList: { visible: true },
    //     insertUnorderedList: { visible: true },
    //     undo: { visible: true },
    //     redo: { visible: true },
    //     indent: { visible: true },
    //     outdent: { visible: true },
    //     removeFormat: { visible: true },
    //     increaseFontSize: { visible: true },
    //     decreaseFontSize: { visible: true }
    //   }
    // });
    $('#job_time_log_note').summernote({
      toolbar: [
          ['headline', ['style']],
          ['style', ['bold', 'italic', 'underline', 'superscript', 'subscript', 'strikethrough', 'clear']],
          ['textsize', ['fontsize']],
          ['alignment', ['ul', 'ol', 'paragraph', 'lineheight']],
      ]
    });
  }
  
  function change_assign_user_for_job(project_job_id,user_id){
    $("#task_loader,.fixed_loader").show();
    wus_confirm('Do you want to enter Time Log for the existing user before changing the assigned user?', function (confirmed){
      if(confirmed){
        $("#task_loader,.fixed_loader").hide();
        get_time_log_form(project_job_id)
        $("#timeLogModal").modal("show");
        return false;
      }
      else{

        $.ajax({
          url: "/change_assign_user_for_job",
          data: {project_job_id: project_job_id, user_id: user_id},
          async: false,
          success: function(data){ 
            $(".job_detail_page").html(data);
            $("#task_loader,.fixed_loader").hide();
          },
          error: function(data){
            alert('Got an error while getting user list.');
            $("#task_loader,.fixed_loader").hide();
          }
        });
        return true;
      }
    });
   
  }
  
  function debounce(delay, obj, callback) {
    var timeout = null;
    return function () {
      //
      // if a timeout has been registered before then
      // cancel it so that we can setup a fresh timeout
      //

      if (timeout) {
        clearTimeout(timeout);
      }

      var args = arguments;
      timeout = setTimeout(function () {


        callback.call();


        timeout = null;
      }, delay);
    };

  }
  function get_jobs_kanban_view(project_id){
    var project_id = project_id;
    $.ajax({
        type: "POST",
        url: "/project_jobs/get_kanban_view",
        dataType: 'json',
        data: {project_id: project_id},
        async: true,
        beforeSend: function(){
          $("#task_loader,.fixed_loader").show();
        },
        success: function(data)
        {
          console.log('sucess........................')
          $("#project-detail-contents").html(data);
        },
        error: function(data) {
          $("#task_loader,.fixed_loader").hide();
        },
        complete: function(data) {
          //alert(data.responseText)
          console.log('complete........................')
          
          // console.log(data.responseText)
          $("#project-detail-contents").html(data.responseText);
          $("#task_loader,.fixed_loader").hide();
          
        }
    });

  }
  function get_project_jobs(project_id){
    alert('get projects jobs called')
    var project_id = project_id;
    $.ajax({
        type: "POST",
        url: "/projects/" + project_id + "/jobs_list",
        dataType: 'json',
        data: {project_id: project_id,page_source: "project"},
        async: true,
        beforeSend: function(){
          $("#task_loader,.fixed_loader").show();
        },
        success: function(data)
        {
          console.log('sucess........................')
         $("#project-detail-contents").html(data);
        },
        error: function(data) {
          $("#task_loader,.fixed_loader").hide();
        },
        complete: function(data) {
          //alert(data.responseText)
          console.log('complete........................')
          console.log($("#project-detail-contents").html())
          console.log(data.responseText)
          $("#project-detail-contents").html(data.responseText);
          $("#task_loader,.fixed_loader").hide();
          
        }
    });
  }
  function get_time_log_form(project_job_id,jtl_id)
  {
    $("#task_loader,.fixed_loader").show();
    var url = "/get_time_log_form?project_job_id=" + project_job_id;
    if(typeof(jtl_id) != undefined)
    {
      url = url + "&jtl_id=" + jtl_id
    }
    $.ajax({
      url: url,
      data: {project_job_id: project_job_id},
      success: function(result){ 
        $("#form_content_time_log").html("").html(result)
        $("#task_loader,.fixed_loader").hide();
      },
      error: function(data){
        $("#task_loader,.fixed_loader").hide();
        alert('Got an error while loading the time log');
      },
      complete: function(result){
      $("#task_loader,.fixed_loader").hide();
      }

    });
  }
  function get_time_log_list(project_job_id,date)
  {
   
    $.ajax({
      url: '/get_job_time_logs',
        type: 'POST',
        data: {date: date,project_job_id: project_job_id},
        dataType: 'json',
        async: true,
        beforeSend: function(){
          $("#task_loader,.fixed_loader").show();
          $(".list_job_time_log").html("");
        },
        complete: function(data) {
          //alert(data.responseText)
          $(".list_job_time_log").html(data.responseText);
          $("#task_loader,.fixed_loader").hide();

        }
    });
  }
  function closeTimeLogPopup(project_job_id){
    $('#timeLogModal').modal('hide');
    refreshTimeLogsList(project_job_id)
    refreshTimeLogStats(project_job_id)
    get_weekly_timesheet('current')
  }
  function removeJobTimeLog(jtl_id,project_job_id){
    $("#task_loader,.fixed_loader").show();
    $.ajax({
      url: "/remove_job_time_log",
      data: {jtl_id: jtl_id},
      method: "delete",
      success: function(result){ 
        $("#task_loader,.fixed_loader").hide();
        refreshTimeLogsList(project_job_id)
        refreshTimeLogStats(project_job_id)
        get_weekly_timesheet('current')
      },
      error: function(data){
        $("#task_loader,.fixed_loader").hide();
        console.log(data)
      },
      complete: function(result){
      $("#task_loader,.fixed_loader").hide();
      }

    });
  }

  function refreshTimeLogsList(project_job_id)
  {
    $("#task_loader,.fixed_loader").show();
    $.ajax({
      url: "/get_job_time_logs?project_job_id=" + project_job_id,
      method: "get",
      success: function(result){ 
      console.log(result)
        $(".list_job_time_log").html("").html(result)
        $("#task_loader,.fixed_loader").hide();
      },
      error: function(data){
        $("#task_loader,.fixed_loader").hide();
        
        alert('Got an error while loading the time log');
      },
      complete: function(result){
        $("#task_loader,.fixed_loader").hide();
      }

    });
  }
  function refreshTimeLogStats(project_job_id)
  {
    $("#task_loader,.fixed_loader").show();
    $.ajax({
      url: "/get_job_time_stats?project_job_id=" + project_job_id,
      method: "get",
      success: function(result){ 
      console.log(result)
        $(".timelog-stat").html("").html(result)
        $("#task_loader,.fixed_loader").hide();
      },
      error: function(data){
        $("#task_loader,.fixed_loader").hide();
        
        alert('Got an error while refreshing the time log statistics');
      },
      complete: function(result){
        $("#task_loader,.fixed_loader").hide();
      }

    });
  }
  