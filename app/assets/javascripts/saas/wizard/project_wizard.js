function showHideTypeRelationProjectWizard(value)
  {
    switch(value) {
      case "Opportunity":
        $(".prj-individual-contact-div-wizard").show();
        $(".prj-lead-div-wizard").show();
        $(".prj-company-contact-div-wizard").hide();
        $("#prj_company_contact_id").removeAttr("required")
        $("#prj_individual_contact_id").prop("required","required")
        $("#prj_deal_id").prop("required","required")
        $("#prj_company_contact_id").val("")
        break;
      case "Contact":
        $(".prj-individual-contact-div-wizard").show();
        $(".prj-lead-div-wizard").hide();
        $(".prj-company-contact-div-wizard").hide();
        $("#prj_company_contact_id").val("")
        $("#prj_company_contact_id").removeAttr("required")
        $("#prj_individual_contact_id").prop("required","required")
        $("#prj_deal_id").removeAttr("required")
        $("#prj_lead_id").val("")
        break;
      case "Organization":
        $(".prj-individual-contact-div-wizard").hide();
        $(".prj-lead-div-wizard").hide();
        $(".prj-company-contact-div-wizard").show();
        $("#prj_individual_contact_id").val("")
        $("#prj_lead_id").val("")
        $("#prj_company_contact_id").prop("required","required")
        $("#prj_individual_contact_id").removeAttr("required")
        $("#prj_deal_id").removeAttr("required")
        break;
      default:
        $(".prj-individual-contact-div-wizard").hide();
        $(".prj-lead-div-wizard").hide();
        $(".prj-company-contact-div-wizard").hide();
        $("#prj_company_contact_id").val("")
        $("#prj_individual_contact_id").val("")
        $("#prj_lead_id").val("")
        $("#prj_company_contact_id").removeAttr("required")
        $("#prj_individual_contact_id").removeAttr("required")
        $("#prj_deal_id").removeAttr("required")
        break;
    }
      //$(".js-source-states").select2();
  }