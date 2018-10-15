  function update_project(id,type){
    if(confirm("Are you sure?")){
      $.ajax({
        type: "PUT",
        url: "/projects/complete_project",
        data: {id:id, type:type},
        success: function(data){         
          $('.dropdown-toggle').removeAttr("onclick");
          if(type=='reopen'){
            $("#project-"+id).find(".triangle-topright-sts").removeClass("completed started").addClass("re-opened").html("<span style ='font-size:11px;'>Re-opened</span>");
            $("#project-"+id).find("ul li:nth-child(2)").html("<a title='Complete project' style='cursor: pointer;' onclick='update_project("+ id +",\"complete\")' href='javascript:void(0)'>Complete</a>");
          }else{
            $("#project-"+id).find(".triangle-topright-sts").removeClass("started re-opened").addClass("completed").html("<span style ='font-size:11px;'>Completed</span>");
            
            $("#project-"+id).find("ul li:nth-child(2)").html("<a title='Re-opened project' style='cursor: pointer;' onclick='update_project("+ id +",\"reopen\")' href='javascript:void(0)'>Re-opened</a>");
          }
          //$("#project-"+id).find(".dropdown").hide();
        },
        error: function(data){
          console.log(data)
          //alert('got an error');
        }
      });
    }
  }
  function getProjectJobGroups(project_job_id,project_id)
  {
    $("#task_loader,.fixed_loader").show();
    $.ajax({
      url: "/get_project_job_group?project_job_id=" + project_job_id,
      method: "get",
      success: function(result){ 
      
        $("#project-job-groups").html("").html(result)
        $("#projectJobGroupModal").modal("show")
        $("#project_job_group_project_id").val(project_id)
        $("#task_loader,.fixed_loader").hide();
      },
      error: function(data){
        $("#task_loader,.fixed_loader").hide();
        
        alert('Got an error while loading the job groups');
      },
      complete: function(result){
        $("#task_loader,.fixed_loader").hide();
      }

    });
  }
  function addJobGroup() {  
      // var jobGroup = $("#txt-add-job-group").val();
      // $("#task_loader,.fixed_loader").show();
      // var project_id = $("#project_job_group_project_id").val()
      // $.ajax({
      //   url: '/create_job_group',
      //     group: 'POST',
      //     data: { name: jobGroup,project_id: project_id },
      //     success: function(res) {
      //         $("#addJobGroup").modal('hide');
      //         $("#list_job_group").html(res);
      //         $("#task_loader,.fixed_loader").hide();
      //     },
      //     error: function(res) {
      //       $("#job_group_error").show();
      //     }
      // });
    }  
  function update_job_group_for_job(project_job_id, job_group_id){
    $("#task_loader,.fixed_loader").show();
    $.ajax({
      url: "/update_job_group_in_job_details",
      dataType: 'json',
      data: {project_job_id: project_job_id, job_group_id: job_group_id},
      async: true,
      complete: function(data){ 
        $("#task_loader,.fixed_loader").hide();
        $("#projectJobGroupModal").modal("hide")
      }
    });
  }
    
 function add_project_user(id){
    $.ajax({
      type: "POST",
      url: "/add_project_user",
      dataType: 'json',
      async: false,
      data: {id: id},
      beforeSend: function(){
        $("#task_loader").show();
      },
      success: function(data)
      {
      },
      error: function(data) {
        $("#task_loader").hide();
      },
      complete: function(data) {
        $("#addUserModal").modal("show");
        $("#add_user_content").html(data.responseText);
        $("#task_loader").hide();
      }
    });
  }
  function  update_project_users(id){
    var add_users = $('#hdn_add_users').val();
    var remove_users = $('#hdn_remove_users').val();
    $.ajax({
      type: "POST",
      url: "/update_project_users",
      data: {remove_user_ids: remove_users, add_user_ids: add_users, id: id},
      beforeSend: function(){
        $("#task_loader").show();
      },
      success: function(result) {
        $("#project-"+id).find("#users-count").text(result["users_count"]);
        $('#task_loader').hide();
        $("#addUserModal").modal("hide");
        $(".modal-backdrop").remove();
      }
    });
  }
  function archive_project(id){
    if(confirm("Are you sure?")){
      $.ajax({
        type: "PUT",
        url: "/projects/archive_project",
        data: {id:id},
        beforeSend: function(){
          $('#task_loader,.fixed_loader').show();
        },
        success: function(data){
          window.location.reload();
        },
        error: function(data){
          alert('got an error');
        }
      });
    }
  }