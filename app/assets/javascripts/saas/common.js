function set_ld_track_event(ld_event, ld_referrer){
  ld_track_event = ld_event;
  ld_track_referrer = ld_referrer;
}
function setSuptrackCookie(cname, cvalue, exdays) {
  localStorage.setItem(cname, cvalue);
}
function getSuptrackCookie(cname) { 
  n= (typeof localStorage.getItem(cname) != 'undefined') ? localStorage.getItem(cname):'';
  return n;
}
jQuery(function(){
    $(".js-source-states").select2();
    $(".decimal_only").keydown(function (event) {
    if(event.shiftKey == true) {
        event.preventDefault();
    }
    if((event.keyCode >= 48 && event.keyCode <= 57) || 
        (event.keyCode >= 96 && event.keyCode <= 105) || 
        event.keyCode == 8 || event.keyCode == 9 || event.keyCode == 37 ||
        event.keyCode == 39 || event.keyCode == 46 || event.keyCode == 190 || event.keyCode == 110) {

    } else {
        event.preventDefault();
    }

    if($(this).val().indexOf('.') !== -1 && (event.keyCode == 190 || event.keyCode == 110))
        event.preventDefault(); 
  });
    var d =new Date(jQuery.now());
    var dtime =d.getFullYear() + "/" + (d.getMonth() + 1) + "/" + d.getDate() + " " + d.getHours() + ":" + d.getMinutes() + ":" + d.getSeconds();
    var referURL = document.referrer;
    // $.post("#{track_lead_url}users/saveprospects",{
    //   clientip:"#{clientIP}",
    //   domain:"#{escape_once(request.env['SERVER_NAME'])}",
    //   urlVisit:window.location.href,
    //   lastmodified:dtime,
    //   referURL:referURL
    // },function(Data){
    // },'json').fail(function(response) {
    //   return true;
    // });
    
    var pages = [];
    // if (!getSuptrackCookie('suptrack_refer')) {
    //   setSuptrackCookie('suptrack_refer', document.referrer); 
    // }
    // if (!getSuptrackCookie('suptrack_usr_code')) {
    //   setSuptrackCookie('suptrack_usr_code', 'suptrack_usr_' + jQuery.now(), 365 * 10);
    // }
    // if (!getSuptrackCookie('suptrack_usr_pages')) {
    //   var url1 = {"urls": [{"url": window.location.href,"lastmodified": dtime}]};
    //   setSuptrackCookie('suptrack_usr_pages', JSON.stringify(url1), 365 * 10);
    // }
    // if (getSuptrackCookie('suptrack_usr_pages')) {
    //   var updatedpage = getSuptrackCookie('suptrack_usr_pages'); 
    //   var parsedpage = JSON.parse(updatedpage);
    //   parsedpage['urls'].push({"url": window.location.href,"lastmodified": dtime});
    //   var finstrprse = JSON.stringify(parsedpage);
    //   setSuptrackCookie('suptrack_usr_pages', finstrprse, 365 * 10);
    // }
    
    // if (getSuptrackCookie('suptrack_usr_name') && getSuptrackCookie('suptrack_usr_code')) {
    //   jQuery.post("#{track_lead_url}users/updatepages",
    //   {
    //     usr_code: getSuptrackCookie('suptrack_usr_code'),
    //     usr_pages: getSuptrackCookie('suptrack_usr_pages')
    //   },
    //   function(data){},
    //   'json').fail(function(response) {
    //     return true;
    //   });
    // }
  });
function trackEventLeadTracker(){
    $.post("#{track_lead_url}users/saveeventtrack",
    {
      'event_name': ld_track_event,
      'eventRefer':  ld_track_referrer,
      'email_id':  user_email_id
    },
    function(data){
      return true;
    }).fail(function(response) {
      return true;
    });
  }
  function validate_getting_started() {
    try{
      email = $("#signup_email").val();
      if(email == "" ){
        $(".signup_email_error").html("Please enter your email address.");
        $("#signup_email").focus();
        return false;
      }
      var atpos = email.indexOf("@");
      var dotpos = email.lastIndexOf(".");
      if (email != '' && (atpos < 1 || dotpos < atpos + 2 || dotpos + 2 >= email.length)) {
        $(".signup_email_error").html("Please enter a valid email address.");
        return false;
      }
      document.cookie = "session_signup="+email;
      window.location.href = "/users/sign-up";
    }
    catch(err) {
      $("#signup_email").html(err.message);
    }
  }

$.ajaxSetup({
    headers: {
        'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    }
});

function sch_slide() {
    //$(".input-group .form-control.srch_fld").animate({width: '130px', backgroundColor: '#fff', color: '#000000'}, 200);
    //$(".input-group .form-control.srch_fld").blur(function () {
    //    if ($(".input-group .form-control.srch_fld").val() == "") {
    //        $(this).animate({width: '100px', backgroundColor: '#b4f5e8', color: '#ffffff'}, 400);
    //    }
    //});
}
$('#dealModal').on('show.bs.modal', function (e) {
//if (!data) return e.preventDefault() // stops modal from being shown
    $("#extension_for_deal").html("")
});
$('#contactModal').on('show.bs.modal', function (e) {
//display_company_div("hide");
});
$("input").prop('maxlength', '100');
$("textarea").prop('maxlength', '250');

$("input,textarea").blur(function () {
    this.value = jQuery.trim((this.value).replace(/^\s*/g, ''))
});
//search field hide show
var targetInput = $('#search_fld #query');
$(document).click(function (e) {
    // Check for left button
    if (e.button == 0) {
        if ($('#search_fld #query').val() == "" && !targetInput.is(document.activeElement)) {
            $('#search_fld').css("opacity", "0.5");
        }
    }
});
$('#search_fld').mouseenter(function () {
    $(this).css("opacity", "1");
}).mouseleave(function () {
    if ($('#search_fld #query').val() == "" && !targetInput.is(document.activeElement)) {
        $(this).css("opacity", "0.5");
    }
});
//end search field hide show
//Reset all the data in modal popup BS3
$('#dealModal,#taskModal,#inviteuserModal,#contactModal,#noteModal').on('shown.bs.modal', function () {
//$(this).find('form')[0].reset();
})

//$('a').tooltip()
// placement examples
//$('a[rel="tooltip"],i,input:checkbox,div,span').powerTip({smartPlacement: true, fadeInTime: 100, fadeOutTime: 200});
$(".trans-toolbar").click(function () {
    $(".trans-toolbar").toggleClass("trans-toolbar-show");
    //$('#datetimepicker').datetimepicker({language: 'en',pick12HourFormat: true})
})


$('#search_form').bind('ajax:before', function (evt, data, status, xhr) {
    $('#loader').show();
});
function deal_list(deal) {
    return "<div> \
    <b><a href='" + deal.result_path + "'>" + deal.title + "</a></b> \
  &nbsp;&nbsp;\
  <b>&bull;</b>&nbsp;&nbsp;\
  Created by <font class='created_by'>" + deal.initiator_name + "</font>&nbsp;&nbsp;\
   <br>\
  <font class='created_by'>Created " + deal.created_at + " &nbsp;&nbsp;</font>\
</div>"
}

function plusandnumbersonly(e)
{    
  var key = e.keyCode;
  if (!(e.shiftKey || (key == 43) || (key == 8) || (key == 9) || (key == 46) || (key >= 35 && key <= 40) || (key >= 48 && key <= 57) || (key >= 96 && key <= 105))) {
      e.preventDefault();
  }
}

function numbersonly(e) {
    if (e.shiftKey || e.ctrlKey || e.altKey) {
        e.preventDefault();
    }
    else {
        var key = e.keyCode;
        if (!((key == 8) || (key == 9) || (key == 46) || (key >= 35 && key <= 40) || (key >= 48 && key <= 57) || (key >= 96 && key <= 105))) {
            e.preventDefault();
        }
    }
}

function onlycharacters(e) {
    var unicode = e.charCode ? e.charCode : e.keyCode;
    if (unicode != 8 && unicode != 46) {
        if ((unicode >= 65 && unicode <= 90) || (unicode >= 112 && unicode <= 122) || unicode == 32 || unicode == 37 || unicode == 39 || unicode == 35 || unicode == 36 || unicode == 9) {
            return true;
        } else {
            return false;
        }
    } else {

        return true;
    }
}
function onlycharactersWithApostrophe(e) {
    var unicode = e.charCode ? e.charCode : e.keyCode;
    if (unicode != 8 && unicode != 46) {
        if ((unicode >= 65 && unicode <= 90) || (unicode >= 112 && unicode <= 122) || unicode == 32 || unicode == 37 || unicode == 39 || unicode == 35 || unicode == 36 || unicode == 9 || unicode == 222) {
            return true;
        } else {
            return false;
        }
    } else {

        return true;
    }
}
function onlycharacterandnumbers(e) {
    var unicode = e.charCode ? e.charCode : e.keyCode;

    if (unicode != 8 && unicode != 46) {
        if ((unicode >= 65 && unicode <= 90) || (unicode >= 97 && unicode <= 122) || unicode == 32 || (unicode >= 48 && unicode <= 57)) {
            return true;
        } else {
            return false;
        }
    } else {
        return true;
    }
}
function onlycharacterandnumberswospace(e) {
    var unicode = e.charCode ? e.charCode : e.keyCode;

    if (unicode != 8 && unicode != 46) {
        if ((unicode >= 65 && unicode <= 90) || (unicode >= 97 && unicode <= 122) || (unicode >= 48 && unicode <= 57)) {
            return true;
        } else {
            return false;
        }
    } else {
        return true;
    }
}
function onlycharacternumberscommadotsquote(e) {
    var unicode = e.charCode ? e.charCode : e.keyCode;

    if (unicode != 8 && unicode != 46) {
        if ((unicode >= 65 && unicode <= 90) || (unicode >= 97 && unicode <= 122) || unicode == 32 || unicode == 39 || unicode == 44 || unicode == 46 || (unicode >= 48 && unicode <= 57) || unicode == 190 || unicode == 222) {
            return true;
        } else {
            return false;
        }
    } else {
        return true;
    }


}
function floatsonly(e) {


    var unicode = e.charCode ? e.charCode : e.keyCode
    if (unicode != 8 && unicode != 46) {
        if (unicode < 48 || unicode > 57) //if not a number
            return false //disable key press
    }
}

function check_float(id, e) {
    var float_val = $("#" + id).val().split(".");
    var unicode = e.charCode ? e.charCode : e.keyCode;
    if (unicode != 8 && unicode != 46) {
        if (unicode < 48 || unicode > 57) //if not a number
            return false //disable key press
    }
    if (float_val[1] != undefined) {
        if (unicode != 8 && unicode != 46) {
            if (float_val[1].length == 2) {
                return false;
            }
        }
    }
}
function formValidation() {
    "use strict";
//alert('form')
    /*----------- BEGIN validationEngine CODE -------------------------*/
    $('#new-contact').validationEngine();

    alert($('#new-contact').validationEngine())
    /*----------- END validationEngine CODE -------------------------*/

}

function reset_notification() {
    $("#bell_notification").removeClass("purple");
    $("#notification_image").html("<img alt='Default-icon-bell' src='/assets/default-icon-bell.png'>")
    $("#notification_popup").css("right", "11px");
    $("#notification_popup").html("<li class='dropdown-header' style='text-align:center;border-radius: 5px 5px 0 0;padding: 6px;'><i class='icon-warning-sign '></i>&nbsp;No Unread Notifications</li>")
}
function set_required_for_file_descrption(obj) {

    //var filelist = document.getElementById('note_attachment').files || [];

    //$('#show_file_name').html("");
    //$('#remove_file_ids').val("");
    //for (var i = 0; i < filelist.length; i++) {
    //    
    //    filename = filelist[i].name
    //    $('#show_file_name').append('<div id= "file_'+i+'"><input type="checkbox"  checked="" onchange="removeNoteFileatt('+ i +');" name="file_chk" style="cursor:pointer;margin-right:5px">'+filename+'<br></div>');
    //}
    if ($("#prv_pub").length <= 0) {
        $('#show_file_name').append('<div id="prv_pub"><label class="checkbox-inline" style="padding-left:0;color:#999999">\
                              <input checked="checked" name="note[is_public]" type="radio" value="false">\
                              Private\
                            </label>\
                            <label class="checkbox-inline" style="color:#999999">\
                              <input  name="note[is_public]" type="radio" value="true">\
                              Public\
                            </label></div>');
    }
    //$("#show_file_name").html(str);
    $("#show_file_name").show("slow");

}
function set_required_for_file_descrption_in_send_email(obj) {

    //var filelist = document.getElementById('note_attachment').files || [];

    //$('#show_file_name').html("");
    //$('#remove_file_ids').val("");
    //for (var i = 0; i < filelist.length; i++) {
    //    
    //    filename = filelist[i].name
    //    $('#show_file_name').append('<div id= "file_'+i+'"><input type="checkbox"  checked="" onchange="removeNoteFileatt('+ i +');" name="file_chk" style="cursor:pointer;margin-right:5px">'+filename+'<br></div>');
    //}
    if ($("#prv_pub").length <= 0) {
        $('.show_file_name').append('<div id="prv_pub"><label class="checkbox-inline" style="padding-left:0;color:#999999">\
                              <input checked="checked" name="note[is_public]" type="radio" value="false">\
                              Private\
                            </label>\
                            <label class="checkbox-inline" style="color:#999999">\
                              <input  name="note[is_public]" type="radio" value="true">\
                              Public\
                            </label></div>');
    }
    //$("#show_file_name").html(str);
    $(".show_file_name").show("slow");

}
var vals = "";
function removeNoteFileatt(id) {
    var checkboxes1 = document.getElementsByName('file_chk');

    vals += id + ",";
    $('#remove_file_ids').val(vals);
    $("#file_" + id).remove();

    if (checkboxes1.length == 0) {


        $(".show_file_name").hide("slow");
        $('.remove_file_ids').val("");
        $("#note_attachment").val("");
    }
    //$("#show_file_name").html("");

    //$("#show_file_name").hide("slow");
}

function selected_dropdown_task_popup(first_name) {
    $('#task_assigned_to option').filter(function () {
        return ($(this).text() == first_name);
    }).prop('selected', true);
}
function show_cc_bcc(type) {
    if (type == "cc") {
        $("#add_cc").hide();
        if ($('#bcc_div').is(':visible')) {
            $('#cc_div').show();
            $('#cc_bcc_div').show();
            $('#cc_link').hide();
            $('#cc_div').removeClass('col-md-12').addClass('col-md-6');
            $('#bcc_div').show();
            $('#bcc_div').removeClass('col-md-12').addClass('col-md-6');
        } else {
            $('#cc_div').show();
            $('#cc_bcc_div').show();
            $('#cc_link').hide();
            $('#bcc_div').hide();
            $('#cc_div').removeClass('col-md-6').addClass('col-md-12');
        }

    } else {
        if ($('#cc_div').is(':visible')) {
            $('#cc_bcc_div').show();
            $('.bcc_link').hide();
            $('#bcc_div').show();
            $('#cc_div').hide();
            $('#cc_div').removeClass('col-md-12').addClass('col-md-6');
            $('#cc_div').show();
            $('#bcc_div').removeClass('col-md-12').addClass('col-md-6');
        }
        else {
            $('#cc_bcc_div').show();
            $('.bcc_link').hide();
            $('#bcc_div').show();
            $('#cc_div').hide();
            $('#bcc_div').removeClass('col-md-6').addClass('col-md-12');
        }

    }
}

function hide_cc_bcc(type) {
    if (type == "cc") {
        $('#cc').val('');
        $('#cc_div').hide();
        $('#cc_link').show();
        $('#add_cc').show();
        if ($('#bcc_div').is(':visible')) {
            $('#bcc_div').removeClass('col-md-6').addClass('col-md-12');
        }
    }
    else if (type == "bcc") {
        $('#bcc').val('');
        $('#bcc_div').hide();
        $('#bcc_link').show();
        $('#add_bcc').show();
        if ($('#cc_div').is(':visible')) {
            $('#cc_div').removeClass('col-md-6').addClass('col-md-12');
        }
    }
}

$(window).on('load', function () {
    $('form input[type="text"].bfh-phone, form input[type="phone"].bfh-phone, span.bfh-phone').each(function () {
        var $phone = $(this);
        $phone.bfhphone($phone.data());
    });
    //$("#user_time_zone").addClass("form-control");
    //$("#user_role_id").addClass("pull-right form-control");
    //$("#user_role_id").css({'width': '130px', 'margin-top': '-8px'})
});

//Prefill extension for country according to country
function prefill_extension(obj, extension_id, hidden_id) {
    if (obj != "") {
        $.get("/get_extension", {id: obj}, function (res) {
            if (res != null) {
                $("#" + extension_id).html("+" + res.extension);
                $("#" + hidden_id).val("+" + res.extension);
            }
        });
    } else {
        $("#" + extension_id).html("");
    }

}
function ogprefill_extension(obj, extension_id, hidden_id) {
    if (obj != "") {
        $.get("/get_extension", {id: obj}, function (res) {
            if (res != null) {
                $("#" + extension_id).html("+" + res.extension);
                $("#" + hidden_id).val("+" + res.extension);
            }
        });
    } else {
        $("#" + extension_id).html("");
    }

}
function get_country_states_org(obj,state_field_id='orgstate') {
    $("#orgstate").html("<option value=''>- State -</option>");
    if (obj != "") {
        $.get("/get_country_states", {id: obj}, function (res) {
            if (res != null) {
                var states = "";
                $.each(res['states'], function (index, value) {
                    states += "<option value='" + value + "'>" + value + "</option>";
                });
                $("#" + state_field_id).append(states).val("Alabama");
            }
        });
    }
}
function get_country_states(obj) {
    $("#state").html("<option value=''>- State -</option>");
    if (obj != "") {
        $.get("/get_country_states", {id: obj}, function (res) {
            if (res != null) {
                var states = "";
                $.each(res['states'], function (index, value) {
                    states += "<option value='" + value + "'>" + value + "</option>";
                });
                $("#state").append(states).val("Alabama");
            }
        });
    }
}
function fetch_country_states(obj) {
    $("#cont_state").html("<option value=''>- State -</option>");
    if (obj != "") {
        $.get("/get_country_states", {id: obj}, function (res) {
            if (res != null) {
                var states = "";
                $.each(res['states'], function (index, value) {
                    states += "<option value='" + value + "'>" + value + "</option>";
                });
                $("#cont_state").append(states);
            }
        });
    }
}
function fetch_country_states_cont(obj,target_state) {
    $(target_state).html("<option value=''>- State -</option>");
    if (obj != "") {
        $.get("/get_country_states", {id: obj}, function (res) {
            if (res != null) {
                var states = "";
                $.each(res['states'], function (index, value) {
                    states += "<option value='" + value + "'>" + value + "</option>";
                });
                $(target_state).append(states);
            }
        });
    }
}
function select_country_state(obj, prefil_state) {

    $("#state, #cont_state").html("<option value=''>- State -</option>");
    if (obj != "") {
        $.get("/get_country_states", {id: obj}, function (res) {
            if (res != null) {
                var states = "";
                $.each(res['states'], function (index, value) {
                    states += "<option value='" + value + "'>" + value + "</option>";
                });
                $("#state, #cont_state").append(states).val(prefil_state);
            }
        });
    }
}
function select_country_state_on_load(country_id,state_obj, prefil_state) {
    
    $(state_obj).html("<option value=''>- State -</option>");
    if (country_id != "") {
        $.get("/get_country_states", {id: country_id}, function (res) {
            if (res != null) {
                var states = "";
                $.each(res['states'], function (index, value) {
                    states += "<option value='" + value + "'>" + value + "</option>";
                });
                $(state_obj).append(states).val(prefil_state);
            }
        });
    }
}
function checkFile_withtype(obj) {
    var flname = $("#" + obj.id).val().split(/\\/).pop();
    var ext = flname.split('.').pop().toLowerCase();
    if (!ext.match('png|gif|jpeg|jpg')) {
        alert("Currently, only photos of .png, .gif, .jpeg and .jpg can be uploaded!");
        $("#" + obj.id).val('')
        return false;
    }
}

function chk_edit_dealvalidation() {
    var prb = $("#deal_probability").val();
    if (prb > 100) {
        $("#err_prb").html('Probability should be between 0 - 100.')
        $("html, body").animate({scrollTop: 0}, 600);
        return false;
    }
}
function chk_validation(type) {
    var url = $("#" + type + "_website").val();
    var prb = $("#deal_probability").val();
    var email_chk = $("#" + type + "_email").val();
    var atpos = email_chk.indexOf("@");
    var dotpos = email_chk.lastIndexOf(".");

    var pattern1 = new RegExp(/^(http:\/\/www\.|https:\/\/www\.)[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/);
    //var pattern2= new RegExp(/^(www|http(?:s)?\:\/\/[A-Za-z][A-Za-z0-9]*(?:_[A-Za-z0-9]+)*[.][A-Za-z][A-Za-z0-9]*(?:_[A-Za-z0-9]+)*([.][A-Za-z][A-Za-z0-9]*(?:_[A-Za-z0-9]+)*)*)$/);
    if (pattern1.test(url) == false) {
        console.log("Invalid url")
        $("#err_msg").html('Invalid Url')
        return false;
    }
    if (prb > 100) {
        console.log("Probability should be between 0 - 100")
        $("#err_prb").html('Probability should be between 0 - 100.')
        $("html, body").animate({scrollTop: 0}, 600);
        return false;
    }
    if (email_chk != '' && (atpos < 1 || dotpos < atpos + 2 || dotpos + 2 >= email_chk.length)) {
        $("#email_err").html('Please enter a valid email address.')
        console.log("Please enter a valid email address.")
        $("html, body").animate({scrollTop: 0}, 600);
        return false;
    }
    else {
        $("#email_err").html('')
        return true;
    }
}
function validate_email(type) {
    var email_id = $("#" + type + "").val();

    var atpos = email_id.indexOf("@");
    var dotpos = email_id.lastIndexOf(".");
    if (email_id != '' && (atpos < 1 || dotpos < atpos + 2 || dotpos + 2 >= email_id.length)) {
        $("#email_err").show();
        $("#email_err").html('Please enter a valid email address.')
        $("#email_err_i").html('Please enter a valid email address.')
        $("#email_err_usr").html('Please enter a valid email address.')
        return false;
    }

    else {
        $("#email_err").hide();
        $("#email_err").html('')
        $("#email_err_i").html('')
        $("#email_err_usr").html('')
    }
}
function validate_email_contact() {
    var chk_con_ty = $("#chk_con_type").val();
    if (chk_con_ty == "individual")
        var email_con = $("#email").val();
    else
        var email_con = $("#company_email").val();

    var atpos = email_con.indexOf("@");
    var dotpos = email_con.lastIndexOf(".");
    if (email_con != '' && (atpos < 1 || dotpos < atpos + 2 || dotpos + 2 >= email_con.length)) {
        $("#email_err_con").show();
        $("#email_err_ind").show();
        $("#email_err_con").html('Please enter a valid email address.')
        $("#email_err_ind").html('Please enter a valid email address.')
        return false;
    }
    else {
        $("#email_err_con").hide();
        $("#email_err_ind").hide();
        $("#email_err_con").html('')
        $("#email_err_ind").html('')
    }
}
//Need to be optimize
function validate_send_email() {
    var docDescription = $("#message").val();
    if (docDescription != "") {
        var docDesc1 = docDescription.replace(/(?:&nbsp;|<br>)/g, ' ');
        var dd = docDesc1.replace(/^\s+/g, "")

        if (dd.length == 0) {
            $("#email_err_msg").html('Message cannot be blank.')
            return false;
        }
        else {
            $("#email_err_msg").html("");
        }
    }
    else {
        $("#email_err_msg").html('Message cannot be blank.')
    }
    var email_to = $("#to").val();
    var email_cc = $("#cc").val();
    var email_bcc = $("#bcc").val();

    var atpos = email_to.indexOf("@");
    var atpos_cc = email_cc.indexOf("@");
    var atpos_bcc = email_bcc.indexOf("@");

    var dotpos = email_to.lastIndexOf(".");
    var dotpos_cc = email_cc.lastIndexOf(".");
    var dotpos_bcc = email_bcc.lastIndexOf(".");

    if (email_to != '' && (atpos < 1 || dotpos < atpos + 2 || dotpos + 2 >= email_to.length)) {
        $("#email_err_to").html('Please enter a valid email address.')
        return false;
    }
    else {
        $("#email_err_to").html('')
    }

    if (email_cc != '' && (atpos_cc < 1 || dotpos_cc < atpos_cc + 2 || dotpos_cc + 2 >= email_cc.length)) {
        $("#email_err_cc").html('Please enter a valid email address.')
        return false;
    }
    else {
        $("#email_err_cc").html('')
    }

    if (email_bcc != '' && (atpos_bcc < 1 || dotpos_bcc < atpos_bcc + 2 || dotpos_bcc + 2 >= email_bcc.length)) {
        $("#email_err_bcc").html('Please enter a valid email address.')
        return false;
    }
    else {
        $("#email_err_bcc").html('')
    }
}
function reset_email_err_msg() {
    $("#email_err_bcc").html('');
    $("#email_err_cc").html('');
    $("#email_err_to").html('');
}

function disable_text(e) {
    var unicode = e.charCode ? e.charCode : e.keyCode;
    if (unicode != 9)
        e.preventDefault();
}

/*$(function(){
 var current_li_id = $(".activ_mnu").attr('id');
 $("#menu-top-nav-menu").on('mouseover','li',function (event) {
 var hover_li_id = event.currentTarget.id;
 $("#"+current_li_id).removeClass('activ_mnu');
 $("#"+hover_li_id).addClass('activ_mnu');
 }).on('mouseout','li',function (event) {
 var hover_li_id = event.currentTarget.id;
 $("#"+hover_li_id).removeClass('activ_mnu');
 $("#"+current_li_id).addClass('activ_mnu');
 });
 });*/
function showImageForCrop(obj) {
    if (checkFile_withtype(obj) == true) {
        //alert('coming here');

        //$('#crop_loader').show();
        //    var user_id = $("#user_id").val();
        //    $.get("/user_save_tmp_img",{user_id: user_id },function(res){
        //      if(res != null){
        //       $("#crop_data").html(res);
        //       $('#crop_loader').hide();
        //      }
        //    });
    }
}
function social_authenticate(auth_url) {
    window.location.href = auth_url;
}
var url = window.location.pathname;
$(document).keydown(function (e) {
    $('input[type=text], input[type=email], textarea').on("keydown blur", function (e) {
        if (e.shiftKey && (e.which == 188 || e.which == 190)) {
            e.preventDefault();
            $('.do_not_allow').remove();
            if (url != '/' || (url == '/' && $("#is_login").val() == 1)) {
                $(this).after("<span class='do_not_allow' style='margin-left:55px;color:#ff0000;'>Note: HTML tags are not allowed.</span>");
            }
        }
    });

    $('input[type=text], input[type=email], textarea').blur(function () {
        var VAL = $(this).val();
        var regex = /<(.|\n)*?>/
        if (VAL.match(regex)) {
            $(this).val((VAL.replace(regex, "")));
            if (url != '/' || (url == '/' && $("#is_login").val() == 1)) {
                $('.do_not_allow').remove();
                $(this).after("<span class='do_not_allow' style='margin-left:55px;color:#ff0000;'>Note: HTML tags are not allowed.</span>");
            }
        }
    });
});

jQuery(document).ready(function( $ ) {
    // $('.counter').counterUp({
    //     delay: 10,
    //     time: 1000
    // });
});
$(function(){
    $("#typed").typed({
        stringsElement: $('#typed-strings'),
        typeSpeed: 100,
        backDelay: 1000,
        loop: true,
        contentType: 'html', 
        loopCount: false,
        callback: function(){ foo(); },
        resetCallback: function() { newTyped(); }
    });

    $(".reset").click(function(){
        $("#typed").typed('reset');
    });

});

function newTyped(){ /* A new typed object */ }

function foo(){ console.log("Callback"); }

/*sticky header start*/
 // $(document).ready(function(){   
             
 //     var stickyHeaderTop = $('header').height();
 //      if( $(window).scrollTop() > stickyHeaderTop ) {
 //             $("header").addClass("sticky_header");
 //             $("ul.menu").css("display","none");
 //             $("ul.nav-form").css("display","block");

 //         } else {
 //             $("header").removeClass("sticky_header");
 //             $("ul.menu").css("display","block");
 //             $("ul.nav-form").css("display","none");
 //         }
 //     if(window.location.pathname != "/users/sign_in" && window.location.pathname != "/users/sign_up"){
 //         $(window).scroll(function(){
 //             if( $(window).scrollTop() > stickyHeaderTop ) {
 //                 $("header").addClass("sticky_header"); 
 //                 $("ul.menu").css("display","none");
 //                 $("ul.nav-form").css("display","block");
 //             } else {
 //                 $("header").removeClass("sticky_header");
 //                 $("ul.menu").css("display","block");
 //                 $("ul.nav-form").css("display","none");
 //             }
 //         });
 //     }
 //     else{
 //         $("header").css({"position":"fixed"});
 //         $(".nav-form").css({"display":"none"});
 //     }
 // });
/*sticky header end*/
 
function getStages(id){
  $(".select-stage-inlead-list.stages-list").html("<img src='/assets/ajax-loader2.gif'/>");
    $.ajax({
      url: "/get_lead_stages",
      data: {id: id},
      success: function(data){ 
        //alert("Success");
        $(".select-stage-inlead-list.stages-list").html("").html(data);
      },
      error: function(data){
        $("#task_loader").hide();
        alert('Got an error while changing Stage.');
      }
    });
  }
  function getLeadStages(id,page){
  $(".select-stage-inlead-list.stages-list").html("<div style='text-align:center;margin-top:70px'><img src='/assets/ajax-loader2.gif'/></div>");
    $.ajax({
      url: "/get_lead_stages",
      data: {id: id,page: page},
      success: function(data){ 
        //alert("Success");
        $(".select-stage-inlead-list.stages-list").html("").html(data);
      },
      error: function(data){
        $("#task_loader").hide();
        alert('Got an error while changing Stage.');
      }
    });
  }
  //setTimeout("$('.alert').fadeOut('slow')", 10000);
  
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

  $(function() {
    return $(".modal").on("show.bs.modal", function() {
      var curModal;
      curModal = this;
      $('.do_not_allow').remove();
      $(".modal").each(function() {
        if (this !== curModal) {
          $(this).modal("hide");
        }
      });
    });
  });

  $(document).ready(function() {
    var wh= screen.height - 235; 
    var min_height = wh.toString()+"px"; 
    //var ww=$(window).width();
    $('.fix_in_app_footer').css({"min-height": min_height});
    // if ($("body").height() < ($(window).height())) {
    //   $(".footer-after-login").addClass("fixed_in_app_footer");
    // }else{
    //   $(".footer-after-login").css("bottom","0")
    // }

    // if ($("body").height() < $(window).height()) {
    //   $(".footer-after-login").addClass("fixed_in_app_footer");
    // }

  });

  function show_alert_message(priority,msg){
    //priority should be: success, warning, danger
    //$(document).trigger("add-alerts", [{'message': "" ,'priority': priority}]);
    $(".close-toast").remove();
    if(priority == "success"){
      //$(".alert.alert-success").html("").html("<div class='data-box'><button class='close' data-dismiss='alert'>×</button><div>"+msg+"</div></div>");
      $("#toast-container").html("<div class='close-toast animated fadeInDown toast-success' aria-live='polite' style='display: block;'><button type='button' class='toast-close-button' role='button'>×</button><div class='toast-message'>"+msg+"</div></div>");
    }
    else if(priority == "warning"){
      //$(".alert.alert-warning").html("").html("<div class='data-box'><button class='close' data-dismiss='alert'>×</button><div>"+msg+"</div></div>");
      $("#toast-container").html("<div class='close-toast animated fadeInDown toast-warning' aria-live='polite' style='display: block;'><button type='button' class='toast-close-button' role='button'>×</button><div class='toast-message'>"+msg+"</div></div>");
    }else{
      //$(".alert.alert-danger").html("").html("<div class='data-box'><button class='close' data-dismiss='alert'>×</button><div>"+msg+"</div></div>");
      $("#toast-container").html("<div class='close-toast animated fadeInDown toast-error' aria-live='polite' style='display: block;'><button type='button' class='toast-close-button' role='button'>×</button><div class='toast-message'>"+msg+"</div></div>");
    }
    //$(".data-box").css({"height":"39px"});
    //$(".data-box div").css({"display":"inline-block","position":"relative"});
    setTimeout(function(){ $('.close-toast').fadeOut();}, 12000); 
  }
  $(document).ready(function() {
    //initialize_tooltipster();
  });
  
  function initialize_tooltipster(){
    // $('.tooltip').tooltipster({
    //   interactive: true,
    //   distance: 0,
    //   selfDestruction: false,
    //   functionPosition: function(instance, helper, position){
    //     // position.coord.top += 10;
    //     // position.coord.left += 10;
    //     return position;
    //   }
    // });
  }

  function wus_confirm(msg, callback){
    $("#WUSConfirmPopup").show();
    $(".confirm_msg_sec").html(msg);
    
    $(".confirm_ok").off("click").on('click',function(){
        $("#WUSConfirmPopup").hide();
        callback(true);
        return false;
    })
    $(".confirm_close").off("click").on('click',function(){
        $("#WUSConfirmPopup").hide();
        callback(false);
        return false;
    })
    // var return_val = swal({
    //     title: "",
    //     text: msg,
    //     type: "warning",
    //     showCancelButton: true,
    //     confirmButtonColor: "#DD6B55",
    //     closeOnConfirm: true,
    //     closeOnCancel: true 
    // },
    // function (isConfirm) {
    //     if (isConfirm) {
    //         swal("","Your Request has been processed soon","success")
    //         callback(true);
    //         return_val= true;
    //     } 
    //     else {
    //         swal("","","error")
    //         return_val= false;
    //     }
    // });
    // alert(return_val)
    // if(return_val == true)
    // {
    //     callback(true);

    //     swal("Your Request has been processed");
    // }
    // else
    // {
    //     //swal("Booyah!");
    // }
    
  }



  function validate_email_field(){
      $("input[type='email']").blur(function(){
        var email_chk = $(this).val();
        if(email_chk == "" || email_chk == null){
          show_alert_message("warning",'Please enter an email address.');
          return false;
        }
        var atpos = email_chk.indexOf("@");
        var dotpos = email_chk.lastIndexOf(".");

        var pattern1 = new RegExp(/^(http:\/\/www\.|https:\/\/www\.)[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/);

        if (email_chk != '' && (atpos < 1 || dotpos < atpos + 2 || dotpos + 2 >= email_chk.length)) {
            show_alert_message("warning",'Please enter a valid email address.');
            return false;
        }
      });
  }

  $(window).scroll(function() {

    if ($(this).scrollTop()>20)
     {
        $('.self_hosted_header_image').fadeOut();
     }
    else
     {
      $('.self_hosted_header_image').fadeIn();
     }
  });
  $.fn.modal.prototype.constructor.Constructor.DEFAULTS.backdrop = 'static';
  $('form select').each(
    function(index){  
      var input = $(this);
      if(input.val()==""){
        input.css("color","#999");
      }
    }
  );
  $('form select').each(
    function(index){  
      var input = $(this);
      input.on("change",function(){
        if(input.val()==""){
          input.css("color","#999");
        }else{
          input.css("color","#000");
        }
      })
    }
  );

function getParameterByName(name, url) {
    if (!url) {
      url = window.location.href;
    }
    name = name.replace(/[\[\]]/g, "\\$&");
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
}
function getMonthName(monthNumber) {
    var months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[monthNumber - 1];
}
function toDate(dateStr) {
  var parts = dateStr.split("-")
  return new Date(parts[0], parts[1] , parts[2])
}
setTimeout(function(){ $('.fadeInDown').fadeOut();}, 12000);

function validate_phone_number(obj) {
    var number = $(obj).val();
    var filter = /^((\+[1-9]{1,4}[ \-]*)|(\([0-9]{2,3}\)[ \-]*)|([0-9]{2,4})[ \-]*)*?[0-9]{3,4}?[ \-]*[0-9]{3,4}?$/;
    if (filter.test(number)) {
        return true;
    }
    else {
        return false;
    }
}