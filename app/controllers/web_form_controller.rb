class WebFormController < ApplicationController
	before_filter :authenticate_admin, :except => [:thank_you]
	skip_before_filter :authenticate_user!, :only => [:thank_you]
	def new
		
	end
	# Display all web forms
	def index
		@web_forms = @current_organization.web_forms.order("id DESC")
		unless @web_forms.present?
			redirect_to "/web_form/create"
		end
		@total_deals = @current_organization.deals.where("web_form_id IS NOT NULL").count
	end
	# Save web form
	def create
		web_form = WebForm.new
		web_form.form_name = params[:web_form][:form_name]
		web_form.organization_id = @current_organization.id
		web_form.created_by = @current_user.id
		web_form.user_responsible = params[:web_form][:user_responsible]
		web_form.source_id = params[:web_form][:source_id]
		web_form.is_display_thank_you_page = params[:web_form][:is_display_thank_you_page]
		web_form.send_email_notification = params[:web_form][:send_email_notification]
		if params[:web_form][:send_email_notification].to_i == 1
			web_form.email_to = params[:web_form][:email_to]
		end
		web_form.field_names = params[:web_form][:field_names]
		if params[:web_form][:is_display_thank_you_page] == "false"
			redirect_url = params[:web_form][:external_link]
			redirect_url = redirect_url.include?("http://") ? redirect_url : "http://#{redirect_url}"
			web_form.external_link = redirect_url
		end
		if web_form.save
			web_form.update_column :form_html_code, "<div style='text-align:center;width:80%;margin:50px auto;border:1px solid #999;border-radius:3px;padding:10px;background: #eee;'><h1 style='margin:0 0 20px'>Contact Us</h1><form action='"+request.protocol+""+request.host_with_port+"/create_web_form_lead' method='post'><input type='hidden' name='form_unique_id' value='#{web_form.form_unique_id}'>" + params[:web_form][:form_html_code] + "<br><input type='submit' value='Submit' style='border: 1px solid #4CAF50;background: #4CAF50;color: #fff;padding: 10px 75px;font-size: 16px;border-radius: 3px;'><br></form>"
			flash[:notice] = "Web form saved successfully."
			redirect_to "/manage_web_form"
		else
			flash[:error] = "Some went wrong.!!!"
			render "/web_form/create"
		end
	end
	def thank_you
		respond_to do |format|
		  format.html { render :layout => false }
		end
	end
	# Get html code of selected fields
	def generate_form
		fields = params[:fields].split(",")
		html_code = ""
		fields.each do |field_name|
			if field_name == "First Name"
				html_code << "<input type='text' placeholder='First Name' name='first_name' style='width:100%;padding:3px;height: 30px;border: 1px solid #aaa;font-size: 12px;' required><br>"
			elsif field_name == "Last Name"
				html_code << "<br><input type='text' placeholder='Last Name' name='last_name' style='width:100%;padding:3px;height: 30px;border: 1px solid #aaa;font-size: 12px;' required><br>"
			elsif field_name == "Email"
				html_code << "<br><input type='email' placeholder='Email' name='email' style='width:100%;padding:3px;height: 30px;border: 1px solid #aaa;font-size: 12px;' autocomplete='off' required><br>"
			elsif field_name == "Phone"
				html_code << "<br><input type='text' placeholder='Phone' name='work_phone' style='width:100%;padding:3px;height: 30px;border: 1px solid #aaa;font-size: 12px;' required><br>"
			elsif field_name == "Title"
				html_code << "<br><input type='text' placeholder='Title' name='title' style='width:100%;padding:3px;height: 30px;border: 1px solid #aaa;font-size: 12px;' required><br>"
			elsif field_name == "Country"
				html_code << get_country_dropdown
			elsif field_name == "Description"
				html_code << "<br><textarea style='resize: none; height: 120px;width:100%;padding:3px;height: 80px;border: 1px solid #aaa;font-size: 12px;' placeholder='Description' name='description' required></textarea><br>"
			elsif field_name == "Industry"
				html_code << "<br><input type='text' placeholder='Industry' name='industry' style='width:100%;padding:3px;height: 30px;border: 1px solid #aaa;font-size: 12px;' required><br>"
			elsif field_name == "Website"
				html_code << "<br><input type='text' placeholder='Website' name='website' style='width:100%;padding:3px;height: 30px;border: 1px solid #aaa;font-size: 12px;' required><br>"
			end
		end
		# html_code << ""
		render text: html_code
	end
	def get_country_dropdown
		return "<br><select name='country_id'  style='width:100%;padding:3px;height: 30px;border: 1px solid #aaa;font-size: 12px;' required='required'><option value=''>- Select your country -</option><option value='1'>Afghanistan</option><option value='2'>Aland Islands</option><option value='3'>Albania</option><option value='4'>Algeria</option><option value='5'>American Samoa</option><option value='6'>Andorra</option><option value='7'>Angola</option><option value='8'>Anguilla</option><option value='9'>Antarctica</option><option value='10'>Antigua and Barbuda</option><option value='11'>Argentina</option><option value='12'>Armenia</option><option value='13'>Aruba</option><option value='14'>Australia</option><option value='15'>Austria</option><option value='16'>Azerbaijan</option><option value='17'>Bahamas</option><option value='18'>Bahrain</option><option value='19'>Bangladesh</option><option value='20'>Barbados</option><option value='21'>Belarus</option><option value='22'>Belgium</option><option value='23'>Belize</option><option value='24'>Benin</option><option value='25'>Bermuda</option><option value='26'>Bhutan</option><option value='27'>Bolivia</option><option value='28'>Bonaire, Sint Eustatius and Saba</option><option value='29'>Bosnia and Herzegovina</option><option value='30'>Botswana</option><option value='31'>Bouvet Island</option><option value='32'>Brazil</option><option value='33'>British Indian Ocean Territory</option><option value='34'>Brunei</option><option value='35'>Bulgaria</option><option value='36'>Burkina Faso</option><option value='37'>Burundi</option><option value='38'>Cambodia</option><option value='39'>Cameroon</option><option value='40'>Canada</option><option value='41'>Cape Verde</option><option value='42'>Cayman Islands</option><option value='43'>Central African Republic</option><option value='44'>Chad</option><option value='45'>Chile</option><option value='46'>China</option><option value='47'>Christmas Island</option><option value='48'>Cocos (Keeling) Islands</option><option value='49'>Colombia</option><option value='50'>Comoros</option><option value='51'>Congo</option><option value='52'>Cook Islands</option><option value='53'>Costa Rica</option><option value='54'>Cote divoire (Ivory Coast)</option><option value='55'>Croatia</option><option value='56'>Cuba</option><option value='57'>Curacao</option><option value='58'>Cyprus</option><option value='59'>Czech Republic</option><option value='60'>Democratic Republic of the Congo</option><option value='61'>Denmark</option><option value='62'>Djibouti</option><option value='63'>Dominica</option><option value='64'>Dominican Republic</option><option value='65'>Ecuador</option><option value='66'>Egypt</option><option value='67'>El Salvador</option><option value='68'>Equatorial Guinea</option><option value='69'>Eritrea</option><option value='70'>Estonia</option><option value='71'>Ethiopia</option><option value='72'>Falkland Islands (Malvinas)</option><option value='73'>Faroe Islands</option><option value='74'>Fiji</option><option value='75'>Finland</option><option value='76'>France</option><option value='77'>French Guiana</option><option value='78'>French Polynesia</option><option value='79'>French Southern Territories</option><option value='80'>Gabon</option><option value='81'>Gambia</option><option value='82'>Georgia</option><option value='83'>Germany</option><option value='84'>Ghana</option><option value='85'>Gibraltar</option><option value='86'>Greece</option><option value='87'>Greenland</option><option value='88'>Grenada</option><option value='89'>Guadaloupe</option><option value='90'>Guam</option><option value='91'>Guatemala</option><option value='92'>Guernsey</option><option value='93'>Guinea</option><option value='94'>Guinea-Bissau</option><option value='95'>Guyana</option><option value='96'>Haiti</option><option value='97'>Heard Island and McDonald Islands</option><option value='98'>Honduras</option><option value='99'>Hong Kong</option><option value='100'>Hungary</option><option value='101'>Iceland</option><option value='102'>India</option><option value='103'>Indonesia</option><option value='104'>Iran</option><option value='105'>Iraq</option><option value='106'>Ireland</option><option value='107'>Isle of Man</option><option value='108'>Israel</option><option value='109'>Italy</option><option value='110'>Jamaica</option><option value='111'>Japan</option><option value='112'>Jersey</option><option value='113'>Jordan</option><option value='114'>Kazakhstan</option><option value='115'>Kenya</option><option value='116'>Kiribati</option><option value='117'>Kosovo</option><option value='118'>Kuwait</option><option value='119'>Kyrgyzstan</option><option value='120'>Laos</option><option value='121'>Latvia</option><option value='122'>Lebanon</option><option value='123'>Lesotho</option><option value='124'>Liberia</option><option value='125'>Libya</option><option value='126'>Liechtenstein</option><option value='127'>Lithuania</option><option value='128'>Luxembourg</option><option value='129'>Macao</option><option value='130'>Macedonia</option><option value='131'>Madagascar</option><option value='132'>Malawi</option><option value='133'>Malaysia</option><option value='134'>Maldives</option><option value='135'>Mali</option><option value='136'>Malta</option><option value='137'>Marshall Islands</option><option value='138'>Martinique</option><option value='139'>Mauritania</option><option value='140'>Mauritius</option><option value='141'>Mayotte</option><option value='142'>Mexico</option><option value='143'>Micronesia</option><option value='144'>Moldava</option><option value='145'>Monaco</option><option value='146'>Mongolia</option><option value='147'>Montenegro</option><option value='148'>Montserrat</option><option value='149'>Morocco</option><option value='150'>Mozambique</option><option value='151'>Myanmar (Burma)</option><option value='152'>Namibia</option><option value='153'>Nauru</option><option value='154'>Nepal</option><option value='155'>Netherlands</option><option value='156'>New Caledonia</option><option value='157'>New Zealand</option><option value='158'>Nicaragua</option><option value='159'>Niger</option><option value='160'>Nigeria</option><option value='161'>Niue</option><option value='162'>Norfolk Island</option><option value='163'>North Korea</option><option value='164'>Northern Mariana Islands</option><option value='165'>Norway</option><option value='166'>Oman</option><option value='167'>Pakistan</option><option value='168'>Palau</option><option value='169'>Palestine</option><option value='170'>Panama</option><option value='171'>Papua New Guinea</option><option value='172'>Paraguay</option><option value='173'>Peru</option><option value='174'>Phillipines</option><option value='175'>Pitcairn</option><option value='176'>Poland</option><option value='177'>Portugal</option><option value='178'>Puerto Rico</option><option value='179'>Qatar</option><option value='180'>Reunion</option><option value='181'>Romania</option><option value='182'>Russia</option><option value='183'>Rwanda</option><option value='184'>Saint Barthelemy</option><option value='185'>Saint Helena</option><option value='186'>Saint Kitts and Nevis</option><option value='187'>Saint Lucia</option><option value='188'>Saint Martin</option><option value='189'>Saint Pierre and Miquelon</option><option value='190'>Saint Vincent and the Grenadines</option><option value='191'>Samoa</option><option value='192'>San Marino</option><option value='193'>Sao Tome and Principe</option><option value='194'>Saudi Arabia</option><option value='195'>Senegal</option><option value='196'>Serbia</option><option value='197'>Seychelles</option><option value='198'>Sierra Leone</option><option value='199'>Singapore</option><option value='200'>Sint Maarten</option><option value='201'>Slovakia</option><option value='202'>Slovenia</option><option value='203'>Solomon Islands</option><option value='204'>Somalia</option><option value='205'>South Africa</option><option value='206'>South Georgia and the South Sandwich Islands</option><option value='207'>South Korea</option><option value='208'>South Sudan</option><option value='209'>Spain</option><option value='210'>Sri Lanka</option><option value='211'>Sudan</option><option value='212'>Suriname</option><option value='213'>Svalbard and Jan Mayen</option><option value='214'>Swaziland</option><option value='215'>Sweden</option><option value='216'>Switzerland</option><option value='217'>Syria</option><option value='218'>Taiwan</option><option value='219'>Tajikistan</option><option value='220'>Tanzania</option><option value='221'>Thailand</option><option value='222'>Timor-Leste (East Timor)</option><option value='223'>Togo</option><option value='224'>Tokelau</option><option value='225'>Tonga</option><option value='226'>Trinidad and Tobago</option><option value='227'>Tunisia</option><option value='228'>Turkey</option><option value='229'>Turkmenistan</option><option value='230'>Turks and Caicos Islands</option><option value='231'>Tuvalu</option><option value='232'>Uganda</option><option value='233'>Ukraine</option><option value='234'>United Arab Emirates</option><option value='235'>United Kingdom</option><option value='236'>United States</option><option value='237'>United States Minor Outlying Islands</option><option value='238'>Uruguay</option><option value='239'>Uzbekistan</option><option value='240'>Vanuatu</option><option value='241'>Vatican City</option><option value='242'>Venezuela</option><option value='243'>Vietnam</option><option value='244'>Virgin Islands, British</option><option value='245'>Virgin Islands, US</option><option value='246'>Wallis and Futuna</option><option value='247'>Western Sahara</option><option value='248'>Yemen</option><option value='249'>Zambia</option><option value='250'>Zimbabwe</option></select><br>"
	end
	def enable_disable_form
		web_form = @current_organization.web_forms.find_by_form_unique_id(params[:form_unique_id])
		web_form.update_attributes :is_active => params[:form_action] == 'disable' ? false : true
		flash[:notice] = "Form status changed successfully.."
		redirect_to "/manage_web_form"
	end
	def get_html_code
		web_form = @current_organization.web_forms.find(params[:form_id])
		render text: web_form.form_html_code
	end
end
