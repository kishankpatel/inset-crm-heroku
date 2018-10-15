
function open_crm_modal(crm_name){
    $(".choose_crm").hide();
    if(crm_name == "zoho_crm"){
      $("#ImportContactModal .modal-title").html("<span class='fal fa-file-import'></span> Import Contact From Zoho CRM");
      $("#ref_site").val("http://www.zohocrm.com");
      $(".import_contact_form").attr("action","/import_contact_from_zoho_crm");
      $(".download_sample_csv").hide();
      $(".download_sample_bulk_csv").hide();
    }
    if(crm_name == "sugar_crm"){
      $("#ImportContactModal .modal-title").html("<span class='fal fa-file-import'></span> Import Contact From Sugar CRM");
      $("#ref_site").val("http://www.sugarcrm.com");
      $(".import_contact_form").attr("action","/import_contact_from_sugar_crm");
      $(".download_sample_csv").hide();
      $(".download_sample_bulk_csv").hide();
    }
    if(crm_name == "fatfree_crm"){
      $("#ImportContactModal .modal-title").html("<span class='fal fa-file-import'></span> Import Contact From Fatfree CRM");
      $("#ref_site").val("http://www.fatfreecrm.com");
      $(".import_contact_form").attr("action","/import_contact_from_fatfree_crm");
      $(".download_sample_csv").hide();
      $(".download_sample_bulk_csv").hide();
    }
    if(crm_name == "other_crm"){
      $("#ImportContactModal .modal-title").html("<span class='fal fa-file-import'></span> Import Contact From Other CRM");
      $("#ref_site").val("Others");
      $(".import_contact_form").attr("action","/import_contact_from_other_crm");
      $(".download_sample_csv").show();
      $(".download_sample_bulk_csv").hide();
    }
    if(crm_name == "bulk_contact"){
      $("#ImportContactModal .modal-title").html("<span class='fal fa-file-import'></span> Bulk Contact Upload");
      $("#ref_site").val("Bulk Contact");
      $(".import_contact_form").attr("action","/import_bulk_contact");
      $(".download_sample_csv").hide();
      $(".download_sample_bulk_csv").show();
    }    
  }

  function show_crm_radio(){
     $(".choose_crm").show(); 
  }

  $(function(){
    if(r_ctrl == 'contacts' && r_act=='index')
    {
      $('#alphabet_value').val('all');
      var Ajax3Contacts = {
        active: false,
        call: function(){
            if (this.active===false) {
                this.active=true;
                var self=this;
                jqxhr=$.ajax({
            beforeSend: function(xhr) {
            xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
            $("#list_buttons .panel").find(".panel-collapse").append("<div class='ldrimg' style='display: block; left: 35%; position: absolute; text-align: center; top: 10%; vertical-align: middle;'> <img  src='/assets/ajax-loader2.gif'/></div>");
            },
            type: "POST",
            url: "/get_more_contacts?page=" + $("#contactpageno").val(),
            data: {selected_tab:$('#selected_tab').val(),letter:$("#alphabet_value").val()},
            success: function(data){
              cldurl = "#{ENV['cloudfront']}"
              if(data != null && data.length > 0)
              {
                var str="";
                var prev_fl="";
                var prevh4exist = true;
                var isfirst=false;
                var validchars="ABCDEFGHIJKLMNOPQRSTUVWXYZ";
                var validsmallchars="abcdefghijklmnopqrstuvwxyz";
                var firstchar = data[0][13];
                var firstchardiv= data[0][13];
                var popup_menu = "";
                if(validchars.indexOf(firstchar) === -1 && validsmallchars.indexOf(firstchar) === -1 || firstchar=="")
                {  
                  firstchar="#";
                  firstchardiv="-";
                }
                else
                {
                  firstchar=firstchar.toUpperCase();
                  firstchardiv=firstchardiv.toUpperCase();
                }
               
                if(data.length > 0)
                {
                  if(typeof($(".panel").find("#head"+firstchardiv).html()) == 'undefined')  
                  {
                    prevh4exist=false;
                    
                  }
                }
                var headexist = 1;
              
                //alert('here');
                $.each(data, function(index) {
                    firstchar = data[index][13];
                    firstchardiv= data[index][13];
                    if(validchars.indexOf(firstchar) === -1 && validsmallchars.indexOf(firstchar) === -1  || firstchar=="")
                    {  
                      //firstchar="#";
                      firstchardiv="-";
                    }
                    else
                    {
                      firstchar=firstchar.toUpperCase();
                      firstchardiv=firstchardiv.toUpperCase();
                    }
                    
                    headexist = $("#head"+firstchardiv).length.toString();
                  
                    //str = "<div class='panel-body grey_act' ><span class='glyphicon glyphicon-play' style='font-size: 9px;top:0'></span><a onclick='display_contact_data_ajax("+ data[index][17] +","+ data[index][0]+");' href='#'>"+data[index][6]+"</a></div>"
                   if(data[index][6] != ""){
                    str+="<div class='panel-body grey_act' >\
                          <span class='glyphicon glyphicon-play' style='font-size: 9px;top:0'></span>\
                          <a  id='contact_"+ data[index][0] + "' onclick=\"display_contact_data_ajax('"+ data[index][17] + "'," + data[index][0] +");make_select(this);\" href='javascript:' >"+data[index][6]+"</a>\
                          </div>";
                    }     
                    
                  prev_fl = firstchardiv;
                  //alert(str);
                  $("#head" + prev_fl).find("#list_scrollTo").append(str);
                  str="";
                });
                
                //$("#liHead" + prev_fl ).find("ul:first").append(str);
                $("#contactpageno").val(eval($("#contactpageno").val())+1 );
              }
              else
              {
                //alert("No record found");
              }
            },
            complete:function() {
                $("#list_buttons .panel").find(".panel-collapse .ldrimg").remove();
                self.active=false;
                $('li.li-contacts').mouseover(function (e) {
                  e.stopPropagation();
                  $('.actions', this).show();
                });
                $('li.li-contacts').mouseout(function (e) {
                  e.stopPropagation();
                  $('.actions', this).hide();
                });            
                $( "li.li-contacts" ).hover(
                  function() {
                  div_open=$(this).find("div.open")
                  $(div_open).removeClass("open")
                  $(this).find("div.contact_listing_setting").show();
                  }, function() {
                  $(this).find("div.contact_listing_setting").hide();
                });
                $("#task_loader,.fixed_loader").hide();
                
                //$('#list_scrollTo').bind('scroll', function(){if($(this).scrollTop() + $(this).innerHeight()>=$(this)[0].scrollHeight){alert('nice call');Ajax3Contacts.call();} })
                //alert($('#list_buttons .panel-collapse.in').html());
                $('#list_buttons .panel-collapse').find('#list_scrollTo').unbind('scroll');
                $('#list_buttons .panel-collapse.in').find('#list_scrollTo').bind('scroll', function(){if($(this).scrollTop() + $(this).innerHeight()>=$(this)[0].scrollHeight){Ajax3Contacts.call();} })
                hightlight_name();
            }
          });
         }
        }
      };
      // list view and grid view 
      $('#datatable').DataTable();
    }
  });

  function display_list_view_contacts(){
    $('#task_loader,.fixed_loader').show();
    $.ajax({
      type: "GET",
      url: "/display_list_view",
      success: function(res){
        $("#contact-view-page").html(res);
        $('#task_loader,.fixed_loader').hide();
      }
    });
  }
    function display_grid_view(){
    $('#task_loader,.fixed_loader').show();
    $.ajax({
      type: "GET",
      url: "/display_grid_view",
      success: function(res){
        $("#contact-view-page").html(res);
        $('#task_loader,.fixed_loader').hide();
      }
    });
  }

  function display_contact_data_ajax(type,id){
    $("#task_loader,.fixed_loader").show();
    $.ajax({
      beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));$("#overlay_newpop1").show();$("#pop_new1").show();},
      type: "POST",
      url: "/get_contact_ajax",
      data: {contact_type:type,id:id},
      success: function(data){
       $('html, body').animate({ scrollTop: 0 }, 'slow');
       $("#contact_detail").html(data);
       $("#last_added").hide();
      }
    });
  }
  function get_contact_data()
  {
    $("#task_loader,.fixed_loader").show();
    var page=$("#contactpageno").val();
    var type="all";
    Ajax3Contacts.call();
  }
  
  function get_contact_per_alphabet(letter){
    if(letter == "*")
    {  $("#alphabet_value").val("");alpha = "-";}
    else if(letter == "-")
    {  $("#alphabet_value").val("-");alpha = "-";}
    else
    {
      alpha = eval('String.fromCharCode(' + letter + ')');
      $("#alphabet_value").val(alpha);
    }
    //alert('clicked');
    $("#contactpageno").val("1");
    $("#panel-body").html("");
    $("#head"+alpha).find("#list_scrollTo").html('');
    $("#list_buttons .panel").find(".panel-collapse").removeClass('in');
    Ajax3Contacts.call();
  }

  function make_select_contacts(elem){
  $(elem).parents("#list_buttons").find('.panel-body').removeAttr("style")
   $(elem).parents("#list_buttons").find('.panel-body').find('.glyphicon').removeClass('glyphicon-forward').addClass('glyphicon-play');
  $(elem).siblings('.glyphicon').removeClass('glyphicon-play').addClass('glyphicon-forward');
  $(elem).parent().css({'font-size': '15px','font-weight': 'bold','font-color': '#000', 'background-color': '#eee' });
  }
  
  