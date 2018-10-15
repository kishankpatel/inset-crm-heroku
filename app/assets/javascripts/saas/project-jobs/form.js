function validate_repeat_form() {
    var repeat_type = $("#job_repeat_type").val();
    var repeat_start = $("#repeat-datetimepicker").val();
    var repeat_occurrences = $("#job_repeat_occurrences").val();
    var repeat_end_on = $("#end-on-datetimepicker").val();
    $("#project_job_repeat_type").val(repeat_type);
    $("#project_job_repeat_start").val(repeat_start);

    var repeat_start_date = $("#repeat-datetimepicker").val()
    var job_start_date = $("#start-datetimepicker1").val()
    var x = new Date(repeat_start_date);
    var y = new Date(job_start_date);  
    if(x < y){
      show_alert_message("danger", "Repeat start date can not be less than job start date.");
      return false;
    }

    if($("input[id='repeat_end_on']:checked").val() == "on" && repeat_end_on == ""){
      $("#end_on_err").text("Please select the repeat end date.");
      return false;
    }else{
      $("#project_job_repeat_end_on").val(repeat_end_on);
    }
    if($("input[id='repeat_end_after']:checked").val() == "after" && repeat_occurrences == ""){
      $("#occurrence_err").text("Please provide the number of occurrences.");
      return false;
    }else{
      $("#project_job_repeat_occurrences").val(repeat_occurrences);
    }
    if(repeat_end_on != "" && repeat_start != ""){
      if(new Date(repeat_end_on) < new Date(repeat_start)){
        show_alert_message("danger", "Reccurrence End date can not be less than reccurrence start date.");
        $("#project_job_is_repeat").removeAttr("checked").val("false");
        $("#end-on-datetimepicker").val("");
        return false;
      }else{
        $("#project_job_is_repeat").prop("checked",true).val("true");
      }
    }
    $("#jobRepeatModal").modal("hide");
    return false;
  };

  function countChecked() {
    var total = [];
    if($( "input[name='notify_email_ids']:checked" ).length == $( "input[name='notify_email_ids']" ).length){
      $("#checkAll").attr("checked");
    }
    $( "input[name='notify_email_ids']:checked" ).not('#checkAll').each(function(){
      total.push($(this).attr("value"));
    });
    $( "#project_job_notify_email_ids" ).val(total);
    if($(this).attr("id") != "checkAll"){
      $("#checkAll").removeAttr("checked");
    }
         
  };

  function initiateJobsForm(){

    $("#checkAll").click(function () {
       $("input[name='notify_email_ids']").not(this).prop('checked', this.checked);
    });
    countChecked();   
    $( "input[type=checkbox]" ).on( "click", countChecked );
    $("#end-on-datetimepicker").on("click", function (e) {
      $("#end_on_err").text("")
    });


    $('#custom-add-type').on("keypress",function(e) {
      if(e.which == 13) {
        create_custom_job_type($.trim($(this).val()));
        e.preventDefault();
        $(".job_type").click();
        return false;
      }
    });
    $('#project_job_description').summernote({
    toolbar: [
        ['headline', ['style']],
        ['style', ['bold', 'italic', 'underline', 'superscript', 'subscript', 'strikethrough', 'clear']],
        ['textsize', ['fontsize']],
        ['alignment', ['ul', 'ol', 'paragraph', 'lineheight']],
    ] 
    });
  
   $("#project_job_is_repeat").on("change",function (){

    toggleJobRepeat(this)
      // if (this.checked == true) {
      //   $("#jobRepeatModal").modal("show");
      //   $("#project_job_is_repeat").val("true");
      // }else{
      //   $("#project_job_is_repeat").val("false");      
      // }
      // $('#project-job-repeat-form')[0].reset();
    });

    var nwdate = new Date();
    nwdate.setDate(nwdate.getDate() - 1); 
    $('.datetimepicker1').datetimepicker({minDate: nwdate, useCurrent: false,  format: 'MM/DD/YYYY',pickTime: false}).on('change', function(){
      $(this).blur();
    });

   
    $('input:radio[name="repeat_end"]').on("change",function(){

      if($(this).val() == 'after'){
        $("#job_repeat_occurrences").removeAttr("disabled");
        $("#end-on-datetimepicker").prop("disabled",true);
        $("#end_on_err").text("");
        $(".occ_msg").show();
      }else{
        $("#job_repeat_occurrences").prop("disabled",true);
        $("#end-on-datetimepicker").removeAttr("disabled");
        $("#occurrence_err").text("");
        $(".occ_msg").hide();
      }
    });
    $("ul#job-type-dropdown-menu li").on("click",function() {
      
      $("#job-type-toggle").val($.trim($(this).text()));
      $("#project_job_project_job_type_id").val($(this).val());
    });
    $("ul#job-group-dropdown-menu li").click(function() {
      $(".job-group-toggle").val($.trim($(this).text()));
      $("#project_job_project_job_group_id").val($(this).val());
    });

    $('#custom-add-group').on("keypress",function(e) {
      if(e.which == 13) {
        create_custom_job_group($.trim($(this).val()))
      }
    });
    $(".save-job-btn").on("click",function(event){
      validate_job_desc($(this).closest('form')); 
      $("#submit_type").val("save");
    });
    $(".add-more-job-btn").on("click",function(event){
      validate_job_desc($(this).closest('form'));
      $("#submit_type").val("save and add");
    });
    var start_date = new Date();
    $("#start-datetimepicker1").on("dp.change", function (e) {
      start_date = new Date(e.date);
      //alert(start_date);
    });
    $("#end-datetimepicker1").on("dp.change", function (e) {
      end_date = new Date(e.date);
      if(start_date > end_date){
        $("#end-datetimepicker1").val("");
        show_alert_message("danger","Due date must be greater than start date.");
        $(this).blur();
        return false;
      }
    });
  }
 $(document).ready(function () {
  initiate_job_group_type();
  if(r_ctrl == 'project_jobs' && (r_act == 'new' || r_act == 'edit'))
  {
      //$("#checkAll").prop( "checked", false );
      $("#checkAll").click(function () {
         $("input[name='notify_email_ids']").not(this).prop('checked', this.checked);
      });

      var countChecked = function() {
        var total = [];
        if($( "input[name='notify_email_ids']:checked" ).length == $( "input[name='notify_email_ids']" ).length){
          $("#checkAll").attr("checked");
        }
        $( "input[name='notify_email_ids']:checked" ).not('#checkAll').each(function(){
          total.push($(this).attr("value"));
        });
        $( "#project_job_notify_email_ids" ).val(total);
        if($(this).attr("id") != "checkAll"){
          $("#checkAll").removeAttr("checked");
        }
             
      };
      countChecked();   
      $( "input[type=checkbox]" ).on( "click", countChecked );
      $("#end-on-datetimepicker").on("click", function (e) {
        $("#end_on_err").text("")
      });


      $('#custom-add-type').on("keypress",function(e) {
        if(e.which == 13) {
          create_custom_job_type($.trim($(this).val()));
          e.preventDefault();
          $(".job_type").click();
          return false;
        }
      });
      $('#project_job_description').summernote({
      toolbar: [
          ['headline', ['style']],
          ['style', ['bold', 'italic', 'underline', 'superscript', 'subscript', 'strikethrough', 'clear']],
          ['textsize', ['fontsize']],
          ['alignment', ['ul', 'ol', 'paragraph', 'lineheight']],
      ] 
      });

      var nwdate = new Date();
      nwdate.setDate(nwdate.getDate() - 1); 
      $('.datetimepicker1').datetimepicker({minDate: nwdate, useCurrent: false,  format: 'MM/DD/YYYY',pickTime: false}).on('change', function(){
        $(this).blur();
      });

     
      $('input:radio[name="repeat_end"]').on("change",function(){

        if($(this).val() == 'after'){
          $("#job_repeat_occurrences").removeAttr("disabled");
          $("#end-on-datetimepicker").prop("disabled",true);
          $("#end_on_err").text("");
          $(".occ_msg").show();
        }else{
          $("#job_repeat_occurrences").prop("disabled",true);
          $("#end-on-datetimepicker").removeAttr("disabled");
          $("#occurrence_err").text("");
          $(".occ_msg").hide();
        }
      });
      $(".save-job-btn").on("click",function(event){
        validate_job_desc($(this).closest('form')); 
        $("#submit_type").val("save");
      });
      $(".add-more-job-btn").on("click",function(event){
        validate_job_desc($(this).closest('form'));
        $("#submit_type").val("save and add");
      });
      var start_date = new Date();
      $("#start-datetimepicker1").on("dp.change", function (e) {
        start_date = new Date(e.date);
        //alert(start_date);
      });
      $("#end-datetimepicker1").on("dp.change", function (e) {
        end_date = new Date(e.date);
        if(start_date > end_date){
          $("#end-datetimepicker1").val("");
          show_alert_message("danger","Due date must be greater than start date.");
          $(this).blur();
          return false;
        }
      });
    }  
  }); 
  function toggleJobRepeat(obj){
   
    if (obj.checked == true) {
          $("#jobRepeatModal").modal("show");
          $("#project_job_is_repeat").val("true");
        }else{
          $("#project_job_is_repeat").val("false");      
        }
        $('#project-job-repeat-form')[0].reset();
  }
  function validate_job_desc(form){
    var action = 1;
    if( $(form).find("#project_job_description").val() == "" || $(form).find("#project_job_description").val() == null ){
      action = 0;
      $(".job_desc_err").html("Please add job description.");
      $(".create_new_job_page .wysiwyg").click();
    }else{
      $(".job_desc_err").html("");
    }

    if(action == 0){
      event.preventDefault();
      return false;
    }
  }

  function initiate_job_group_type(){    
    
    $("ul#job-type-dropdown-menu li").on("click",function() {
      $("#job-type-toggle").val($.trim($(this).text()));
      $("#project_job_project_job_type_id").val($(this).val());
      $("ul#job-type-dropdown-menu").hide()
    });
    $("ul#job-type-dropdown-menus-form li").on("click",function() {
      $(".job-type-toggled").val($.trim($(this).text()));
      $(this).closest("form").find("#project_job_project_job_type_id").val($(this).val());
      $("ul#job-type-dropdown-menus-form").hide()
    });
    $("ul#job-group-dropdown-menu li").click(function() {
      $(".job-group-toggle").val($.trim($(this).text()));
      $("#project_job_project_job_group_id").val($(this).val());
      $("ul#job-group-dropdown-menu").hide()
    });
    $("ul#job-group-dropdown-menus-form li").click(function() {
      $(".job-group-toggle").val($.trim($(this).text()));
      $(this).closest("form").find("#project_job_project_job_group_id").val($(this).val());
      $("ul#job-group-dropdown-menus-form").hide()
    });
    
    
  }


  // function change_mnth_days(from_id, to_id )
  // {
  //     period_val=$("#"+from_id).val();
  //     date=period_val.split(" ")[0];
  //     time = period_val.split(" ")[1];
  //     year = date.split("/")[2]
  //     month = date.split("/")[0]
  //     day = date.split("/")[1]
  //     $("#"+to_id).val(year+"-"+month+"-"+day + " " +time);
  // }
  // //$("#project_job_description").on('change',function(){
  // //  validate_job_desc();
  // //})

 


  // function validate_number(){
  //   var occurrence = parseInt($("#job_repeat_occurrences").val());
  //   if(occurrence > parseInt(365)){
  //     $("#occurrence_err").text("Sorry! you can not enter more than 365 occurrences.");
  //     $("#job_repeat_occurrences").val(365);
  //   }
  // }

  

  function create_custom_job_type(new_val){
    var new_job_type = new_val;
    $.ajax({
      url: '/create_job_type',
      type: 'POST',
      async: true,
      data: {name: new_job_type, custom: "true" },
      success: function(res) {
        if(res['status'] == "success"){
          if(res['type'] == "new"){
            $("#job-type-dropdown-menu").append("<li class='selected' value='" + res['id']+ "' tabindex='0' style='padding-left:15px;'>"+ res['name'] +"</li>")
          }
          show_alert_message("success", res['msg']);
          $("#project_job_project_job_type_id").val(res['id']);
          $(".job-type-toggle").val(res['name']).prop("required",true);
          $("#custom-add-type").val("");
          initiate_job_group_type();
        }else{
          $("#job-type-dropdown-menu").show();
          $("#custom-add-type").css("border","1px solid #F00").focus().val("");
          show_alert_message("danger", res['msg']);
          $(".job-type-toggle").prop("placeholder","Job Type");
        }
      },
    });
  }

  

  function create_custom_job_group(new_val){
    var new_job_group = new_val;
    var project_id = $("#project_job_project_id").val();
    if(project_id != null && project_id != "" && project_id != undefined){
      $.ajax({
        url: '/create_job_group',
        type: 'POST',
        async: true,
        dataType:'json',
        data: {name: new_job_group, custom: "true", project_id: project_id },
        success: function(res) {
          if(res['status'] == "success"){
            if(res['type'] == "new"){
              $("#job-group-dropdown-menu").append('<li class="selected" tabindex="0" value="'+ res['id'] +'" style="padding-left: 15px;">'+ res['name'] +'<span class="close"></span></li>');
              $("#job-group-dropdown-menus-form").append('<li class="selected existing" tabindex="0" value="'+ res['id'] +'" style="padding-left: 15px;">'+ res['name'] +'<span class="close"></span></li>');
            }
            show_alert_message("success", res['msg']);
            $("#project_job_project_job_group_id").val(res['id']);
            $(".job-group-toggle").val(res['name']).css("padding-left", "15px");;
            $("#custom-add-group").val("");
            $("#custom-add-group-job").val("");
            initiate_job_group_type();
          }else{
            $("#job-group-dropdown-menu").show();
            $("#custom-add-group").css("border","1px solid #F00").focus().val();
            show_alert_message("danger", res['msg']);
            $(".job-group-toggle").prop("placeholder","Job Group");
          }
        },
      });
    }
  }

  
  $(window).click(function() {
    $('#job-type-dropdown-menu').hide();
    $('#job-group-dropdown-menu').hide();
    var type_val = $.trim($("#custom-add-type").val());
    var group_val = $.trim($("#custom-add-group").val());
    // if(type_val != ""){
    //   create_custom_job_type(type_val)
    // }
    // if(group_val != ""){
    //   create_custom_job_group(group_val)
    // }
  });

  $('#job_type_dropdown').click(function(event){
    $('#job-type-dropdown-menu').show();
    $('#job-group-dropdown-menu').hide();
  });

  $('#job_group_dropdown').click(function(event){
    $('#job-group-dropdown-menu').show();
    $('#job-type-dropdown-menu').hide();
  });

  $(".dropdown-menu li.selected").css("padding-left", "15px");

  $('#new_project_job').submit( function (event) {
    var button = $('#new_project_job :submit').not($(this));
    button.removeAttr('data-disable-with');
    button.attr('disabled', true);
  });