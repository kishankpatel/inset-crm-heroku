
$(function(){
  var current_user_email;
  $('.submit_btn').on("click",function(e) {
    var email_chk = $(this).closest(".form").find(".user_email").val();
    current_user_email = email_chk;
    var email_err_field = $(this).closest(".form").find(".email_err_msg");
    if(email_chk == "" || email_chk == null){
      email_err_field.html('Please enter an email address.');
      e.preventDefault();
      return false;
    }else{
      var atpos = email_chk.indexOf("@");
      var dotpos = email_chk.lastIndexOf(".");

      if (email_chk != '' && (atpos < 1 || dotpos < atpos + 2 || dotpos + 2 >= email_chk.length)) {
        email_err_field.html('Please enter a valid email address.');
        e.preventDefault();
        return false;
      }
    }
  });

  
  $(".signup-form").bind("ajax:complete", function(evt, data, status, xhr){
    if(data.responseText == "company already exists"){
      show_alert_message("danger", "Oops! The company name is already taken. Please try another one or contact the Super-admin to join.");
    }
    else
    if(data.responseText == "email already exists"){
      show_alert_message("danger", "This Email id is already in use. Please try another one.");
    }
    else
    if(data.responseText == "error"){
      show_alert_message("danger", "Oops! Something went wrong. Please try again.");
    }
    else
    if(data.responseText == "success"){

      var useremail = current_user_email;
      var username = useremail.substring(0, useremail.lastIndexOf("@"));
      setSuptrackCookie('suptrack_usr_name', username, 365 * 10);
      setSuptrackCookie('suptrack_usr_email', useremail, 365 * 10);
      var track_usr_id = "#{clientIP}";
      var track_usr_dmn = 'www.insetcrm.com';
      // jQuery.post("#{track_lead_url}users/saveleads",
      // {
      //   access_key: '', //This is company unique Id
      //   secret_key: '', //This is Domain Unique Id
      //   usr_code: getSuptrackCookie('suptrack_usr_code'),
      //   name :  username,
      //   email :  useremail,
      //   phone : '',
      //   start : '',
      //   typeapps : '',
      //   about : '',
      //   loc : track_usr_id,
      //   domain : track_usr_dmn,
      //   refer : getSuptrackCookie('suptrack_refer')
      // },
      // function(data){
      
      // }).fail(function(response) {
      //   //alert("Success Inserted Force 1");
      // });
      window.location.href = "/getting_started?type=show_onboarding";
      //window.location.href = "/dashboard?type=show_onboarding";
      // window.location.href = "/leads";
      
      // if(getSuptrackCookie('suptrack_usr_name') && getSuptrackCookie('suptrack_usr_code')) {
      //   jQuery.post("#{track_lead_url}users/updatepages",
      //   {
      //     access_key: '', //This is company unique Id
      //     secret_key: '', //This is Domain Unique Id
      //     usr_code: getSuptrackCookie('suptrack_usr_code'),
      //     usr_pages: getSuptrackCookie('suptrack_usr_pages')
      //   },
      //   function(data){
      //     //window.location=HTTP_APP+"users/login";
      //     //alert("Success Inserted");
      //   }).fail(function(response) {
      //     //alert("Success Inserted Force 2");
      //   });
      // }
    }
  });
  $(".user_email").on('keypress',function(){
    $(".email_err_msg").html("");
  });
  $(".user_email").on('change',function(){
    $(".email_err_msg").html("");
  });
});
function setSuptrackCookie(cname, cvalue, exdays) {
  localStorage.setItem(cname, cvalue);
}
function getSuptrackCookie(cname) { 
  n= (typeof localStorage.getItem(cname) != 'undefined') ? localStorage.getItem(cname):'';
  return n;
}