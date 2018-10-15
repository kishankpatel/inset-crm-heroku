function check_uniqueness_of_invoice(invoice_no){
    $.ajax({
      url: '/check_unique_invoice',
      type: 'GET',
      data: {invoice_no: invoice_no},
      success: function(res) {
        if(res==true){
          $("#invoice_no_error").show().html("Invoice number already taken.");
        }else{
          $("#invoice_no_error").hide();
        }
      },
      error: function(res) {
        alert("Something went wrong.");
      }
    }); 
  }

function get_invoice_line_items()
  {
    var project_id = $("#invoice_project_id").val();
    var start_dt = $("#invoice_start_date").val().replace(/\//g, '-');
    var end_dt = $("#invoice_end_date").val().replace(/\//g, '-');
    
    $("#task_loader,.fixed_loader").show();
    $.ajax({
      url: "/get_invoice_line_items?project_id=" + project_id + "&start_date=" + start_dt + "&end_date=" + end_dt,
      method: "get",
      dataType: "json",
      success: function(result){ 
        
        generateInvoiceLineItems(result)
        $("#task_loader,.fixed_loader").hide();
      },
      error: function(data){
        $("#task_loader,.fixed_loader").hide();
        alert('Got an error while loading the line items');
      },
      complete: function(result){
        $("#task_loader,.fixed_loader").hide();
      }

    });
  }
  
function generateInvoiceLineItems(data){
  var rowno = $(".invoice-line-item-rows").find(".fields").length;
  if(rowno <= 0)
  {
     rowno = 0
  } 

  data.forEach(function(element) {
    rowno = rowno + 1;
      str=`<tr class="fields">
              <td class="td_col col_1">
                  <textarea cols="40" columns="10" id="invoice_invoice_items_attributes_${rowno}_description" name="invoice[invoice_items_attributes][${rowno}][description]" onblur="this.value = jQuery.trim((this.value).replace(/^ */g,''))" rows="3" style="outline: none;" class="form-control">${element.note}</textarea>
              </td>
              <td class="td_col col_2">
                  <input class="quantity form-control" id="invoice_invoice_items_attributes_${rowno}_qty" maxlength="7" name="invoice[invoice_items_attributes][${rowno}][qty]" oninput="sum_quantity($(this).val(),$(this))" onkeydown="return numbersonly(event)" size="10" type="text" value="${element.spent_hours}">
                  <input id="invoice_invoice_items_attributes_${rowno}_job_time_log_id" name="invoice[invoice_items_attributes][${rowno}][job_time_log_id]" type="hidden" value="${element.job_time_log_id}">
              </td>
              <td class="td_col col_3">
                  <input class="rate decimal_only  form-control" id="invoice_invoice_items_attributes_${rowno}_rate" name="invoice[invoice_items_attributes][${rowno}][rate]" onblur="sum_rate($(this).val(),$(this));" oninput="sum_rate($(this).val(),$(this))" size="10" type="text" value="${element.billable_hrs}">
              </td>
              <td class="td_col col_4">
                  <input class="hidden_amount  form-control" id="invoice_invoice_items_attributes_${rowno}_amount" name="invoice[invoice_items_attributes][${rowno}][amount]" type="hidden">
                  <span class="display_sum amount">${element.spent_hours * element.billable_hrs}</span>
              </td>
              <td class="td_col col_5">
                  <a href="javascript:void(0)" class="delete_line_item" onclick="remove_items($(this))"><span class="glyphicon glyphicon-trash" style="margin-right: 0;" title="Remove this item"></span>
                  </a>
              </td>
              
              <div class="cb"></div>
              
            </tr>`;
      $(".invoice-line-item-rows").append(str);
      calculate_amount();
    });
  }

function calculate_amount(){
  var total_amount = parseFloat(0.0);
  $(".amount").each(function() {
    if(!isNaN(parseInt($(this).text())) && $(this).text() != ""){
      total_amount = parseFloat(parseInt($(this).text())) + total_amount;
    }else{
      total_amount = total_amount
    }
  });
  if(!isNaN(parseInt(total_amount))){
    $("#sub_total").html(total_amount.toFixed(2));
    $("#sub_total_discount").val(total_amount.toFixed(2));
  }
  amount_payable(total_amount,"0.00")
}