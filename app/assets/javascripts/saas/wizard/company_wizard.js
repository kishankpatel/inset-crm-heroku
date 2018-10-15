$(document).ready(function(){

  $('#contact_company_name').typeahead([{
    name: 'company_contacts',
    valueKey: 'company_name',
    remote: {url: '/get_companies/'+ org_id + '?q=%QUERY'},
    template: '<p><strong>{{company_name}}</strong></p>',
    engine: Hogan
    }]).on('typeahead:selected',onSelectedWizard).on('typeahead:opened',onOpenedWizard).on('keyup', onKeyUpA);
 $('#company_contact_name').typeahead([{
    name: 'company_contacts',
    valueKey: 'company_name',
    remote: {url: '/get_companies/'+ org_id + '?q=%QUERY'},
    template: '<p><strong>{{company_name}}</strong></p>',
    engine: Hogan
    }]).on('typeahead:selected',onSelectedCompanyWizard).on('typeahead:opened',onOpenedWizard).on('keyup', onKeyUpB);
   
  
  function onKeyUpA($e,datum){
    $('#wizard_company_id').val('');
    $("#cont_company").val($(this).val());
  };  
  function onKeyUpB($e,datum){
    $('#wizard_company_contact_id').val('');
    $("#cont_company").val($(this).val());
  };
});


function onSelectedWizard($e,datum){
  $('#wizard_company_id').val(datum.id);
  display_company_data("display_cont_comp_info","wizard_company_id",datum)
}
function onSelectedCompanyWizard($e,datum){
  $('#wizard_company_contact_id').val(datum.id);
  display_company_data("display_comp_info","wizard_company_contact_id",datum)
}
function display_company_data(div,comp_id,datum)
{
  $.ajax({
    type: "POST",
    url: "/display_company_info",
    data: {id: datum.id},
    beforeSend: function(){
      $("#task_loader,.fixed_loader").show();
      // $("#" + comp_id).val("")
    },
    success: function(data)
    {
      console.log(data)

      $("#" + div).html(data);
      $("#task_loader,.fixed_loader").hide();
      $("#" + div).show();
      // show_alert_message("danger", data.responseText);
    },
    error: function(data) {
      show_alert_message("danger", "Oops! Something went wrong.");
      $("#task_loader,.fixed_loader").hide();
    }
  });
}
function onOpenedWizard($e){
 
}