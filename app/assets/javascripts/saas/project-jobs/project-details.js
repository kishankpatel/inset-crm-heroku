  function update_job_type_in_job_details(project_job_id, job_type_id){
    $("#task_loader,.fixed_loader").show();
    $.ajax({
      url: "/update_job_type_in_job_details",
      dataType: 'json',
      data: {project_job_id: project_job_id, job_type_id: job_type_id},
      async: true,
      complete: function(data){ 
        $(".job_detail_page").html(data.responseText);
        $("#task_loader,.fixed_loader").hide();
        initialize_tinymce();
        Dropzone.discover();
      }
    });
  }
  function update_job_group_in_job_details(project_job_id, job_group_id){
    $("#task_loader,.fixed_loader").show();
    $.ajax({
      url: "/update_job_group_in_job_details",
      dataType: 'json',
      data: {project_job_id: project_job_id, job_group_id: job_group_id},
      async: true,
      complete: function(data){ 
        $(".job_detail_page").html(data.responseText);
        $("#task_loader,.fixed_loader").hide();
        initialize_tinymce();
        Dropzone.discover();
      }
    });
  }

  function update_catchup_later_in_job_details(project_job_id){
    $("#task_loader,.fixed_loader").show();
    $.ajax({
      type: 'PUT',
      url: "/update_catchup_later_in_job_details",
      dataType: 'json',
      data: {project_job_id: project_job_id},
      async: true,
      complete: function(data){ 
        $(".job_detail_page").html(data.responseText);
        $("#task_loader,.fixed_loader").hide();
        initialize_tinymce();
        Dropzone.discover();
      }
    });
  }

  function change_priority(project_job_id, priority){
    $("#task_loader,.fixed_loader").show();
    $.ajax({
      url: "/change_priority_for_project_job",
      dataType: 'json',
      data: {project_job_id: project_job_id, priority: priority},
      async: true,
      complete: function(data){ 
        $(".job_detail_page").html(data.responseText);
        $("#task_loader,.fixed_loader").hide();
        initialize_tinymce();
        Dropzone.discover();
      }
    });
  }

  $(function(){
    if(r_ctrl == 'project_jobs' && r_act == 'show')
    {
      initialize_tinymce();
      initializeDropZone()
      $('.editable_estimated_hours').editable({
        url: '/update_estimated_hours?project_job_id='+ prj_job_id,
        pk: 'source',
        mode: 'inline',
        // type: 'combodate',
        // format: 'hh:ii',    
        // viewformat: 'HH:mm',    
        // template: 'HH / mm',    
        // combodate: {
        //         maxHour: 200,
        //         minuteStep: 1
        //    },
        type: 'number',
        step: '0.01',
        placement: 'bottom',
        title: 'Enter estimated hour(s)',   
        data: {custom: 'Enter estimated hour(s)'}, 
        validate: function(value) {
          if($.trim(value) == ''){
            return 'Please enter estimated hour(s)';
          }

          if ($.isNumeric(value) == '') {
              return 'Only numbers are allowed';
          }
          if((parseFloat(value) % 1) > 0.59)
          {
            return 'Please enter minutes upto .59'
          }
        },
        render: function() {
          this.$loading = $($.fn.editableform.loading);        
          this.$div.empty().append(this.$loading);
        },
        success: function(response, newValue) {
          //if(response != "")
          //  $('#source1').attr("data-original-title", response)
          $(".job_detail_page").html(response);
          $("#reAllocateResourceModal").modal("show")
          get_reallocate_resource(prj_job_id,'all')
        }
      });
    }
    $("#showcollapsDescription").on("click",function () {
      $("#description-div").slideToggle(500, function () {
        $("#showcollapsDescription").text(function () {
            $("#description-div").is(":visible") ? $("#showcollapsDescription").html("<span>Collapse Description</span><span class='glyphicon glyphicon-chevron-up' style='font-size:10px;margin-left:3px;'>") : $("#showcollapsDescription").html("<span>Expand Description</span><span class='glyphicon glyphicon-chevron-down' style='font-size:10px;margin-left:3px;'>");
        });
      });
    });
  });
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

  function get_job_types(project_job_id){
    $.ajax({
      url: "/get_job_types",
      data: {project_job_id: project_job_id},
      success: function(data){ 
        $(".job_type_list").html(data);
      },
      error: function(data){
        alert('Got an error while getting user list.');
      }
    });
  }

  function change_priority(project_job_id, priority){
    $("#task_loader,.fixed_loader").show();
    $.ajax({
      url: "/change_priority_for_project_job",
      data: {project_job_id: project_job_id, priority: priority},
      success: function(data){ 
        $(".job_detail_page").html(data);
        $("#task_loader,.fixed_loader").hide();
      },
      error: function(data){
        $("#task_loader,.fixed_loader").hide();
        alert('Got an error while changing priority.');
      }
    });
  }
  function initializeDropZone()
  {
    Dropzone.options.myAwesomeDropzone = {
    // The configuration we've talked about above
    addRemoveLinks: true,
    autoProcessQueue: false,
    uploadMultiple: true,
    parallelUploads: 100,
    maxFiles: 10,
    maxFilesize: 200,
    previewsContainer: ".dropzone-previews",
    // The setting up of the dropzone
    init: function() {
      var myDropzone = this;
      // First change the button to actually tell Dropzone to process the queue.
      this.element.querySelector("input[type=submit]").addEventListener("click", function(e) {
        // Make sure that the form isn't actually being sent.
        if(myDropzone.files.length > 0 && $("#comment_comment").val().trim() != ""){
          myDropzone.processQueue();
          e.preventDefault();
          e.stopPropagation();
        }
        
        //$('#my-awesome-dropzone').trigger('submit');
      });

      // Listen to the sendingmultiple event. In this case, it's the sendingmultiple event instead
      // of the sending event because uploadMultiple is set to true.
      this.on("sendingmultiple", function() {
        // Gets triggered when the form is actually being sent.
        // Hide the success button or the complete form.
      });
      this.on("successmultiple", function(files, response) {
        $("#drop-file-errror").text("");
        $("#comment-submit-btn").removeAttr("disabled");
        $(".job_detail_page").html(response["html_data"]);
        $("#task_loader,.fixed_loader").hide();
        initialize_tinymce();
        Dropzone.discover();
        //$("#comment_images").val(files)
        // Gets triggered when the files have successfully been sent.
        // Redirect user or notify of success.
      });
      this.on("errormultiple", function(files, response) {
        $("#drop-file-errror").css("color","#f00").text("Please upload files upto 200 mb.")
        $("#comment-submit-btn").prop("disabled",true);
        e.preventDefault();
        e.stopPropagation();
        // Gets triggered when there was an error sending the files.
        // Maybe show form again, and notify user of error
      });
    }
  }

  }
function initiateProjectDetailsForms(){
  var date = new Date();
    date.setDate(date.getDate());
    var nwdate = new Date();
    nwdate.setDate(nwdate.getDate() - 1); 

    $('.due_date_for_job').datetimepicker({minDate: nwdate, useCurrent: false,  format: 'MM-DD-YYYY'}).on('dp.change', function(e){
      var d = new Date(e.date);
      var m = parseInt(d.getMonth()) + 1;
      var dt = d.getDate()+"-"+ m +"-"+d.getFullYear();
      $("#task_loader,.fixed_loader").show();
      $.ajax({
      url: "/update_due_date?project_job_id=" + prj_job_id,
      data: {date: dt},
      success: function(data){ 
        $(".bootstrap-datetimepicker-widget").hide();
        fetch_job_content(prj_job_id,'refresh');
        $("#task_loader,.fixed_loader").hide();

        $('#reAllocateResourceModal').modal('show');
        get_reallocate_resource(prj_job_id,'all')
      },
      error: function(data){
        $("#task_loader,.fixed_loader").hide();
        alert('Got an error while updating due date');
      }
    });

    });
}
function update_job_progress(project_job_id, progress){
    $("#task_loader,.fixed_loader").show();
    $.ajax({
      url: "/update_job_progress",
      data: {project_job_id: project_job_id, progress: progress},
      success: function(data){ 
        $(".project_job_progress .progress-bar").css("width",data+"%");
        $(".show_progress").html(data+"%");
        $("#task_loader,.fixed_loader").hide();
      },
      error: function(data){
        $("#task_loader,.fixed_loader").hide();
        alert('Got an error while updating progress of the job.');
      }
    });
  }

  function get_project_job(project_job_id)
  {
    $("#task_loader,.fixed_loader").show();
    $.ajax({
      url: "/get_project_job?id=" + project_job_id,
      data: {id: project_job_id},
      success: function(data){ 
        $("#task_loader,.fixed_loader").hide();
        $("#edit_project_job_detail").html(data)
        $("#editProjectJobModal").modal("show")
        //console.log(data)
      },
      error: function(data){
        $("#task_loader,.fixed_loader").hide();
        alert('Got an error while getting the job.');
      }
    });
  }