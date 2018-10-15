  $( ".custom-frm-inner" ).click(function() {
    $(this).parent().next('.control-label').addClass("control-lbl-add")
  });
  $( ".custom-frm-inner" ).focusout(function() {
    if($(this).val() == ""){
      $(this).parent().next('.control-label').removeClass("control-lbl-add")
    }else{
      $(this).parent().next('.control-label').addClass("control-lbl-add-txt")
    }
  });
  $("#deal_title_task").keypress(function() {
  $('#deal_title_task').addClass('loadinggif');
   setTimeout(hidetaskload, 510)
  });
  
  function display_rec_sec(){
    $('.recurring_task').hide();
    $('.recurring_task_form').show();    
    $('#task_recurring_type_none').prop('checked', true);
    $("#end_datetimepicker").html("");
    $(".recurring_end_date").hide();
    $("#task_rec_end_date").val("");  
    $("#task_rec_end_date").removeAttr("required");
  }
  function hide_rec_sec(){
    $('.recurring_task').show();
    $('.recurring_task_form').hide();
    $("#task_rec_end_date").removeAttr("required");
    $("#end_datetimepicker").html("");
    $(".recurring_end_date").hide();
    $("#task_rec_end_date").val("");  
    $("#task_rec_end_date").removeAttr("required");
  }
  function update_mail()
  {
    if($("#puppy_gooddog").is(':checked'))
     $("#task_notify_email").val(1)
    else
     $("#task_notify_email").val(0)
  }  
  
  $(document).ready(function() {
    $("#task_is_event").click( function(){
      if( $(this).is(':checked')){
        $(".event_space").show(100);
        $("#task_task_type_id").removeAttr('required');
        $("#task_task_type_id").removeAttr('required');
        //$("#task_rec_end_date").removeProp('required');
        
        $("#event_datetimepicker").attr("required", "required");
        $("#task_event_end_date").attr("required", "required");
        $(".task_space").hide(100);
        $(".task_recurring_section").hide(100);
      }else{
        $(".task_space").show(100);
        $(".task_recurring_section").show(100);
        $("#task_task_type_id").attr("required", "required");
        //$("#task_rec_end_date").attr("required", "required");
        $("#event_datetimepicker").removeAttr('required');
        $("#task_event_end_date").removeAttr('required');
        $(".event_space").hide(100);
      }
        
    });
  });
  
  function reset_event(){
    if( $("#task_is_event").is(':checked')){
      $(".event_space").show(100);
      $("#task_task_type_id").removeProp('required');
     // $("#task_rec_end_date").removeProp('required');
      
      $("#event_datetimepicker").attr("required", "required");
      $("#task_event_end_date").attr("required", "required");
      $(".task_space").hide(100);
      $(".task_recurring_section").hide(100);
    }else{
      $(".task_space").show(100);
      $(".task_recurring_section").show(100);
      $("#task_task_type_id").attr("required", "required");
      //$("#task_rec_end_date").attr("required", "required");
      $("#event_datetimepicker").removeAttr('required');
      $("#task_event_end_date").removeAttr('required');
      $(".event_space").hide(100);
    }
    $("#set_is_reminder").val("");
    $("#reminder_datetime").val("");
    $("#reminder-div").hide();
    $("#reminder_datetimepicker").removeAttr("required");
  }
  function reset_recurring_option(){
    $(".recurring_task_form").hide();
    $(".recurring_task").show();
  }
  function reset_end_datepicker(reset_to){
    var due_date=$("#due_date").val();
    if(reset_to == "none"){
      $("#end_datetimepicker").html("");
      $(".recurring_end_date").hide();
      //$("#task_rec_end_date").val("");
    }
    else{
      $(".recurring_end_date").show();
      $("#task_rec_end_date").attr("required", "required");
    }
    if(due_date != "" && typeof(due_date) != "undefined"){
      reset_date=new Date(due_date)
      //var reset_date = $("");
      if(reset_to == "daily"){
        reset_date = reset_date.setDate(reset_date.getDate()+1);
      }else if(reset_to == "weekly"){
        reset_date = reset_date.setDate(reset_date.getDate()+7);
      }else if(reset_to == "monthly"){
        reset_date = reset_date.setMonth(reset_date.getMonth()+1);
      }else if(reset_to == "qtr"){
        reset_date = reset_date.setMonth(reset_date.getMonth()+3);
      }else if(reset_to == "yearly"){
        reset_date = reset_date.setFullYear(reset_date.getFullYear()+1);
      }
      date=new Date(reset_date)
      $('#event_datetimepicker').val(date.format('mm-dd-yyyy HH:MM'));
      $('#task_event_end_date').val(date.format('yyyy-mm-dd HH:MM'));
    }
    if($('#task_recurring_type_none').attr('checked')) {
      $("#task_rec_end_date").removeAttr("required");
    }else{
      $("#task_rec_end_date").attr("required","required");
    } 
  }
  
  function set_event_end_datepicker(){
    var due_date=$("#datetimepicker").val();
    if((due_date != "" && typeof(due_date) != "undefined")) {
      end_date=new Date(due_date)
      end_date = end_date.setHours(end_date.getHours()+1);
      date=new Date(end_date)
      if($("#task_is_event").is(':checked')){
        $('#event_datetimepicker').val(date.format('mm-dd-yyyy HH:MM'));
        $('#task_event_end_date').val(date.format('yyyy-mm-dd HH:MM'));
      }else
        $('#event_datetimepicker').val("")
        $('#event_datetimepicker').data("DateTimePicker").setMinDate(date);
    }
  }
  
  function hidetaskload()
  {
  $('#deal_title_task').removeClass('loadinggif');
  }
  
  // $('#task_form').submit(function() {
  //   if($("#hfield").val() == ""){
  //     //alert("Please assign an Opportunity from auto suggest.");
  //     //return false;
  //   }  
  // });
  $('#task_form').bind('ajax:success', function(evt, data, status, xhr){
  });
  $('#task_form').bind('ajax:before', function(evt, data, status, xhr){
    $('#task_loader,.fixed_loader').show();
   
  });
  
    
   
   $('.assign_task_usr_email').on("change",function() {
      if($(this).val() != ""){
       $('#task_loader,.fixed_loader').show();
       $.get("/get_user_email",{id: $(this).val() },function(res){
           if(res != null){
            $(".assign_mail").val(res.email);
            $('#task_loader,.fixed_loader').hide();
           }
        });
      }else{ $(".assign_mail").val("");}
   });
   

  
  function onSelectedTaskOpp($e,datum){
    console.log("autocompleted");
    console.log(datum);
    var hfield = document.getElementById('hfield');
    $('#taskable_id').val(datum.id)
    console.log(datum.id);
    hfield.value = datum.id;
    ;
    $("#lead_priority").val(datum.priority);
    
  }
  function onOpened($e){
    $("#hfield").val("");
    $("#lead_priority").val("");
  }
   
  function onClosed($e){
    if($("#hfield").val() == ""){
      $("#deal_title").val("");
    }
  }
  function change_mnth_days(from_id, to_id )
  {
      period_val=$("#"+from_id).val();
      if(period_val)
      {
        date=period_val.split(" ")[0];
        time = period_val.split(" ")[1];
        year = date.split("/")[2]
        month = date.split("/")[0]
        day = date.split("/")[1]
        $("#"+to_id).val(year+"-"+month+"-"+day + " " +time);
      }
  }
  function daysInMonth(month,year) {
    return new Date(year, month, 0).getDate();
  }


  function showHideTypeRelation(val,form_obj)
  {
  if( val == "Opportunity" || val == "Deal"){
      $("#taskable_type").val("Opportunity");
      $(".deal_list").show()
      $(".contact_list").hide();
      $(".company_list").hide();
      $("#contact_title_task,#company_value").removeAttr("required");
      $("#deal_title_task").attr("required","required");
      $("#deal_title").attr("required","required");
    }
    else  if( val == "Contact"){
      $("#taskable_type").val("IndividualContact");
      $(".deal_list").hide()
      $(".contact_list").show();
      $(".company_list").hide();
      $("#deal_title_task,#company_value").removeAttr("required");
      $("#deal_title,#company_value").removeAttr("required");
      $("#contact_title_task").attr("required","required");
    }
    else if( val == "Organization"){
      $("#taskable_type").val("CompanyContact");
      $(".deal_list").hide()
      $(".contact_list").hide();
      $(".company_list").show();
      $("#deal_title_task,#contact_title_task").removeAttr("required");
      $("#deal_title,#contact_title_task").removeAttr("required");
      $("#company_value").attr("required","required");
    }
    else if( val == "Project"){
      $("#taskable_type").val("Project");
      $(".deal_list").hide()
      $(".contact_list").show();
      $(".company_list").hide();
      $("#deal_title_task,#company_value").removeAttr("required");
      $("#deal_title,#company_value").removeAttr("required");
      $("#contact_title_task").attr("required","required");
    }
    else{
      $("#taskable_type").val("");
      $(".deal_list").hide()
      $(".contact_list").hide();
      $(".company_list").hide();
      $("#contact_title_task, #company_value").removeAttr("required");
      $("#deal_title_task").attr("required","required");
      $("#deal_title").attr("required","required");
    }
  }
  
  function onSelectedContact($e,datum){
    $("#taskable_id").val(datum.id);
  }
  function onOpened($e){ 
    $("#taskable_id").val('');
  }
  
  function onSelectedCompany($e,datum){
    $("#taskable_id").val(datum.id);
  }
  function onOpenedCompany($e){
    $("#taskable_id").val('');
  }
  function onSelectedProject($e,datum){
    $("#taskable_id").val(datum.id);
  }
  function onOpenedProject($e){
    $("#taskable_id").val('');
  }
  $('#taskModal').on('shown.bs.modal', function() {
    if($('#taskModal').find("#link_with").val()==""){
      $('#taskModal').find("#taskable_type").val("");
      $('#taskModal').find(".deal_list").hide()
      $('#taskModal').find(".contact_list").hide();
      $('#taskModal').find(".company_list").hide();
    }
  });
  $('#scheduleModal').on('shown.bs.modal', function() {
    if($('#scheduleModal').find("#link_with").val()==""){
      $('#scheduleModal').find("#taskable_type").val("");
      $('#scheduleModal').find(".deal_list").hide()
      $('#scheduleModal').find(".contact_list").hide();
      $('#scheduleModal').find(".company_list").hide();
    }
  });
  $(function () {
    if($("#set_is_reminder").val()=="true"){
      $("#is_reminder").prop("checked","checked");
      $("#reminder-div").show();
    }
  });
  $("#is_reminder").on("click", function(){
    if($(this).is(":checked")){
      $("#reminder-div").show();
      $("#reminder_datetimepicker").attr("required","required");
      $("#set_is_reminder").val("true");
    }
    else if($(this).is(":not(:checked)")){
      $("#reminder-div").hide();
      $("#reminder_datetimepicker").removeAttr("required");
      $("#set_is_reminder").val("");
    }
  });

  function view_popup(id)
  {
    $("#taskView").modal('show'); 
    $.ajax({
      url: '/show_task_detail',
      type: 'POST',
      data: {task_id: id},
      success: function(res) {
        $('.all-details').html('').html(res);
         
      },
    });
  }  

  function edit_popup_task(id){
   
    $.ajax({
      type: "POST",
      url: "/edit_task",
      dataType: 'json',
      async: true,
      data: {task_id: id},
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
        $("#form_content").html(data.responseText);
        $("#task_loader").hide();
        $('#clicked_button_ref').val(check_active_tab());
        
      }
    });
  }
    function edit_popup(id){
    $('#taskable_id').val(id);
    $.ajax({
      type: "POST",
      url: "/edit_task",
      dataType: 'json',
      async: false,
      data: {task_id: id},
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
        $("#form_content").html(data.responseText);
        $("#clicked_button_ref").val('taskwidget');
        $("#task_loader").hide();
        //$('a[rel="tooltip"],i,input:checkbox,button,div,span').powerTip({smartPlacement: true,fadeInTime: 100,fadeOutTime: 200});
      }
    });
  }
  
  function check_active_tab(){
    tab_name="all"
    $( "ul.nav-tabs li" ).each(function() {
      if($( this ).hasClass( "active" ))
        tab_name = $( this ).attr("id");
    });
    return tab_name
  }