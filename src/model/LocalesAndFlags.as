package model
{
	import mx.formatters.NumberBaseRoundType;
	import mx.formatters.NumberFormatter;
	import mx.resources.ResourceManager;

	public class LocalesAndFlags
	{

		[Bindable]
		[Embed("../resources/images/flags/flag_united_states.png")]
		private var FlagUnitedStates:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_new_zealand.png")]
		private var FlagNewZealand:Class;

		[Bindable]
		[Embed("../resources/images/flags/flag_spain.png")]
		public var FlagSpain:Class;

		[Bindable]
		[Embed("../resources/images/flags/flag_basque_country.png")]
		public var FlagBasqueCountry:Class;

		[Bindable]
		[Embed("../resources/images/flags/flag_france.png")]
		public var FlagFrance:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_morocco.png")]
		public var FlagMorocco:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_germany.png")]
		public var FlagGermany:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_italy.png")]
		public var FlagItaly:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_poland.png")]
		public var FlagPoland:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_albania.png")]
		public var FlagAlbania:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_belarus.png")]
		public var FlagBelarus:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_bulgaria.png")]
		public var FlagBulgaria:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_cataluna.png")]
		public var FlagCataluna:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_croatia.png")]
		public var FlagCroatia:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_czech_republic.png")]
		public var FlagCzechRepublic:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_denmark.png")]
		public var FlagDenmark:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_belgium.png")]
		public var FlagBelgium:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_netherlands.png")]
		public var FlagNetherlands:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_australia.png")]
		public var FlagAustralia:Class;

		[Bindable]
		[Embed("../resources/images/flags/flag_belize.png")]
		public var FlagBelize:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_canada.png")]
		public var FlagCanada:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_united_kingdom.png")]
		public var FlagUnitedKingdom:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_estonia.png")]
		public var FlagEstonia:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_finland.png")]
		public var FlagFinland:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_luxembourg.png")]
		public var FlagLuxembourg:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_monaco.png")]
		public var FlagMonaco:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_switzerland.png")]
		public var FlagSwitzerland:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_galicia.png")]
		public var FlagGalicia:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_georgia.png")]
		public var FlagGeorgia:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_austria.png")]
		public var FlagAustria:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_liechtenstein.png")]
		public var FlagLiechtenstein:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_greece.png")]
		public var FlagGreece:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_hungary.png")]
		public var FlagHungary:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_iceland.png")]
		public var FlagIceland:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_latvia.png")]
		public var FlagLatvia:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_lithuania.png")]
		public var FlagLithuania:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_norway.png")]
		public var FlagNorway:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_brazil.png")]
		public var FlagBrazil:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_portugal.png")]
		public var FlagPortugal:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_romania.png")]
		public var FlagRomania:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_russia.png")]
		public var FlagRussia:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_serbia_montenegro.png")]
		public var FlagSerbiaMontenegro:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_slovakia.png")]
		public var FlagSlovakia:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_slovenia.png")]
		public var FlagSlovenia:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_argentina.png")]
		public var FlagArgentina:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_chile.png")]
		public var FlagChile:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_bolivia.png")]
		public var FlagBolivia:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_colombia.png")]
		public var FlagColombia:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_costa_rica.png")]
		public var FlagCostaRica:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_dominican_republic.png")]
		public var FlagDominicanRepublic:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_ecuador.png")]
		public var FlagEcuador:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_el_salvador.png")]
		public var FlagElSalvador:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_guatemala.png")]
		public var FlagGuatemala:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_honduras.png")]
		public var FlagHonduras:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_mexico.png")]
		public var FlagMexico:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_nicaragua.png")]
		public var FlagNicaragua:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_panama.png")]
		public var FlagPanama:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_paraguay.png")]
		public var FlagParaguay:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_peru.png")]
		public var FlagPeru:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_puerto_rico.png")]
		public var FlagPuertoRico:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_uruguay.png")]
		public var FlagUruguay:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_venezuela.png")]
		public var FlagVenezuela:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_sweden.png")]
		public var FlagSweden:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_turkey.png")]
		public var FlagTurkey:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_ukraine.png")]
		public var FlagUkraine:Class;
		
		[Bindable]
		[Embed("../resources/images/flags/flag_cuba.png")]
		public var FlagCuba:Class;
		
//		private var af_ZA:Object={code: 'af_ZA', icon: };
		private var sq_AL:Object={code: 'sq_AL', icon: FlagAlbania};
//		private var ar_DZ:Object={code: 'ar_DZ', icon: };
//		private var ar_BH:Object={code: 'ar_BH', icon: };
//		private var ar_EG:Object={code: 'ar_EG', icon: };
//		private var ar_IQ:Object={code: 'ar_IQ', icon: };
//		private var ar_JO:Object={code: 'ar_JO', icon: };
//		private var ar_KW:Object={code: 'ar_KW', icon: };
//		private var ar_LB:Object={code: 'ar_LB', icon: };
//		private var ar_LY:Object={code: 'ar_LY', icon: };
		private var ar_MA:Object={code: 'ar_MA', icon: FlagMorocco};
//		private var ar_OM:Object={code: 'ar_OM', icon: };
//		private var ar_QA:Object={code: 'ar_QA', icon: };
//		private var ar_SA:Object={code: 'ar_SA', icon: };
//		private var ar_SY:Object={code: 'ar_SY', icon: };
//		private var ar_TN:Object={code: 'ar_TN', icon: };
//		private var ar_AE:Object={code: 'ar_AE', icon: };
//		private var ar_YE:Object={code: 'ar_YE', icon: };
//		private var hy_AM:Object={code: 'hy_AM', icon: };
//		private var az_AZ:Object={code: 'az_AZ', icon: };
		private var eu_ES:Object={code: 'eu_ES', icon: FlagBasqueCountry};
		private var be_BY:Object={code: 'be_BY', icon: FlagBelarus};
		private var bg_BG:Object={code: 'bg_BG', icon: FlagBulgaria};
		private var ca_ES:Object={code: 'ca_ES', icon: FlagCataluna};
//		private var zh_HK:Object={code: 'zh_HK', icon: };
//		private var zh_MO:Object={code: 'zh_MO', icon: };
//		private var zh_CN:Object={code: 'zh_CN', icon: };
//		private var zh_SG:Object={code: 'zh_SG', icon: };
//		private var zh_TW:Object={code: 'zh_TW', icon: };
		private var hr_HR:Object={code: 'hr_HR', icon: FlagCroatia};
		private var cs_CZ:Object={code: 'cs_CZ', icon: FlagCzechRepublic};
		private var da_DK:Object={code: 'da_DK', icon: FlagDenmark};
		private var nl_BE:Object={code: 'nl_BE', icon: FlagBelgium};
		private var nl_NL:Object={code: 'nl_NL', icon: FlagNetherlands};
		private var en_AU:Object={code: 'en_AU', icon: FlagAustralia};
		private var en_BZ:Object={code: 'en_BZ', icon: FlagBelize};
		private var en_CA:Object={code: 'en_CA', icon: FlagCanada};
//		private var en_CB:Object={code: 'en_CB', icon: };
//		private var en_IE:Object={code: 'en_IE', icon: };
//		private var en_JM:Object={code: 'en_JM', icon: };
		private var en_NZ:Object={code: 'en_NZ', icon: FlagNewZealand};
//		private var en_PH:Object={code: 'en_PH', icon: };
//		private var en_ZA:Object={code: 'en_ZA', icon: };
//		private var en_TT:Object={code: 'en_TT', icon: };
		private var en_GB:Object={code: 'en_GB', icon: FlagUnitedKingdom};
		private var en_US:Object={code: 'en_US', icon: FlagUnitedStates};
//		private var en_ZW:Object={code: 'en_ZW', icon: };
		private var et_EE:Object={code: 'et_EE', icon: FlagEstonia};
//		private var fo_FO:Object={code: 'fo_FO', icon: };
//		private var fa_IR:Object={code: 'fa_IR', icon: };
		private var fi_FI:Object={code: 'fi_FI', icon: FlagFinland};
		private var fr_BE:Object={code: 'fr_BE', icon: FlagBelgium};
		private var fr_CA:Object={code: 'fr_CA', icon: FlagCanada};
		private var fr_FR:Object={code: 'fr_FR', icon: FlagFrance};
		private var fr_LU:Object={code: 'fr_LU', icon: FlagLuxembourg};
		private var fr_MC:Object={code: 'fr_MC', icon: FlagMonaco};
		private var fr_CH:Object={code: 'fr_CH', icon: FlagSwitzerland};
		private var gl_ES:Object={code: 'gl_ES', icon: FlagGalicia};
		private var ka_GE:Object={code: 'ka_GE', icon: FlagGeorgia};
		private var de_AT:Object={code: 'de_AT', icon: FlagAustria};
		private var de_DE:Object={code: 'de_DE', icon: FlagGermany};
		private var de_LI:Object={code: 'de_LI', icon: FlagLiechtenstein};
		private var de_LU:Object={code: 'de_LU', icon: FlagLuxembourg};
		private var de_CH:Object={code: 'de_CH', icon: FlagSwitzerland};
		private var el_GR:Object={code: 'el_GR', icon: FlagGreece};
//		private var gu_IN:Object={code: 'gu_IN', icon: };
//		private var he_IL:Object={code: 'he_IL', icon: };
//		private var hi_IN:Object={code: 'hi_IN', icon: };
		private var hu_HU:Object={code: 'hu_HU', icon: FlagHungary};
		private var is_IS:Object={code: 'is_IS', icon: FlagIceland};
//		private var id_ID:Object={code: 'id_ID', icon: };
		private var it_IT:Object={code: 'it_IT', icon: FlagItaly};
		private var it_CH:Object={code: 'it_CH', icon: FlagSwitzerland};
//		private var ja_JP:Object={code: 'ja_JP', icon: };
//		private var kn_IN:Object={code: 'kn_IN', icon: };
//		private var kk_KZ:Object={code: 'kk_KZ', icon: };	
//		private var ko_KR:Object={code: 'ko_KR', icon: };	
//		private var ky_KG:Object={code: 'ky_KG', icon: };	
		private var lv_LV:Object={code: 'lv_LV', icon: FlagLatvia};	
		private var lt_LT:Object={code: 'lt_LT', icon: FlagLithuania};
//		private var mk_MK:Object={code: 'mk_MK', icon: };
//		private var ms_BN:Object={code: 'ms_BN', icon: };
//		private var ms_MY:Object={code: 'ms_MY', icon: };
//		private var mr_IN:Object={code: 'mr_IN', icon: };
//		private var mn_MN:Object={code: 'mn_MN', icon: };
		private var nb_NO:Object={code: 'nb_NO', icon: FlagNorway};
		private var nn_NO:Object={code: 'nn_NO', icon: FlagNorway};
		private var pl_PL:Object={code: 'pl_PL', icon: FlagPoland};
		private var pt_BR:Object={code: 'pt_BR', icon: FlagBrazil};
		private var pt_PT:Object={code: 'pt_PT', icon: FlagPortugal};
//		private var pa_IN:Object={code: 'pa_IN', icon: };
		private var ro_RO:Object={code: 'ro_RO', icon: FlagRomania};
		private var ru_RU:Object={code: 'ru_RU', icon: FlagRussia};
//		private var sa_IN:Object={code: 'sa_IN', icon: };
		private var sr_SP:Object={code: 'sr_SP', icon: FlagSerbiaMontenegro};
		private var sk_SK:Object={code: 'sk_SK', icon: FlagSlovakia};
		private var sl_SI:Object={code: 'sl_SI', icon: FlagSlovenia};
		private var es_AR:Object={code: 'es_AR', icon: FlagArgentina};
		private var es_BO:Object={code: 'es_BO', icon: FlagBolivia};
		private var es_CL:Object={code: 'es_CL', icon: FlagChile};
		private var es_CO:Object={code: 'es_CO', icon: FlagColombia};
		private var es_CU:Object={code: 'es_CU', icon: FlagCuba};
		private var es_CR:Object={code: 'es_CR', icon: FlagCostaRica};
		private var es_DO:Object={code: 'es_DO', icon: FlagDominicanRepublic};
		private var es_EC:Object={code: 'es_EC', icon: FlagEcuador};
		private var es_SV:Object={code: 'es_SV', icon: FlagElSalvador};
		private var es_GT:Object={code: 'es_GT', icon: FlagGuatemala};
		private var es_HN:Object={code: 'es_HN', icon: FlagHonduras};
		private var es_MX:Object={code: 'es_MX', icon: FlagMexico};
		private var es_NI:Object={code: 'es_NI', icon: FlagNicaragua};
		private var es_PA:Object={code: 'es_PA', icon: FlagPanama};
		private var es_PY:Object={code: 'es_PY', icon: FlagParaguay};
		private var es_PE:Object={code: 'es_PE', icon: FlagPeru};
		private var es_PR:Object={code: 'es_PR', icon: FlagPuertoRico};
		private var es_ES:Object={code: 'es_ES', icon: FlagSpain};
		private var es_UY:Object={code: 'es_UY', icon: FlagUruguay};
		private var es_VE:Object={code: 'es_VE', icon: FlagVenezuela};
//		private var sw_KE:Object={code: 'sw_KE', icon: };
		private var sv_FI:Object={code: 'sv_FI', icon: FlagFinland};
		private var sv_SE:Object={code: 'sv_SE', icon: FlagSweden};
//		private var ta_IN:Object={code: 'ta_IN', icon: };
//		private var tt_RU:Object={code: 'tt_RU', icon: };
//		private var te_IN:Object={code: 'te_IN', icon: };
//		private var th_TH:Object={code: 'th_TH', icon: };
		private var tr_TR:Object={code: 'tr_TR', icon: FlagTurkey};
		private var uk_UA:Object={code: 'uk_UA', icon: FlagUkraine};
//		private var ur_PK:Object={code: 'ur_PK', icon: };
//		private var uz_UZ:Object={code: 'uz_UZ', icon: };
//		private var vi_VN:Object={code: 'vi_VN', icon: };
		
		
		//This array contains the selectable languages for the exercises
		[Bindable] public var availableLanguages:Array = new Array();
		

		//The selectable GUI languages
		[Bindable] public var guiLanguages:Array = new Array;

		public function LocalesAndFlags()
		{
			
			//		availableLanguages.push(af_ZA);
			availableLanguages.push(sq_AL);
			//		availableLanguages.push(ar_DZ);
			//		availableLanguages.push(ar_BH);
			//		availableLanguages.push(ar_EG);
			//		availableLanguages.push(ar_IQ);
			//		availableLanguages.push(ar_JO);
			//		availableLanguages.push(ar_KW);
			//		availableLanguages.push(ar_LB);
			//		availableLanguages.push(ar_LY);
			availableLanguages.push(ar_MA);
			//		availableLanguages.push(ar_OM);
			//		availableLanguages.push(ar_QA);
			//		availableLanguages.push(ar_SA);
			//		availableLanguages.push(ar_SY);
			//		availableLanguages.push(ar_TN);
			//		availableLanguages.push(ar_AE);
			//		availableLanguages.push(ar_YE);
			//		availableLanguages.push(hy_AM);
			//		availableLanguages.push(az_AZ);
			availableLanguages.push(eu_ES);
			availableLanguages.push(be_BY);
			availableLanguages.push(bg_BG);
			availableLanguages.push(ca_ES);
			//		availableLanguages.push(zh_HK);
			//		availableLanguages.push(zh_MO);
			//		availableLanguages.push(zh_CN);
			//		availableLanguages.push(zh_SG);
			//		availableLanguages.push(zh_TW);
			availableLanguages.push(hr_HR);
			availableLanguages.push(cs_CZ);
			availableLanguages.push(da_DK);
			availableLanguages.push(nl_BE);
			availableLanguages.push(nl_NL);
			availableLanguages.push(en_AU);
			availableLanguages.push(en_BZ);
			availableLanguages.push(en_CA);
			//		availableLanguages.push(en_CB);
			//		availableLanguages.push(en_IE);
			//		availableLanguages.push(en_JM);
			availableLanguages.push(en_NZ);
			//		availableLanguages.push(en_PH);
			//		availableLanguages.push(en_ZA);
			//		availableLanguages.push(en_TT);
			availableLanguages.push(en_GB);
			availableLanguages.push(en_US);
			//		availableLanguages.push(en_ZW);
			availableLanguages.push(et_EE);
			//		availableLanguages.push(fo_FO);
			//		availableLanguages.push(fa_IR);
			availableLanguages.push(fi_FI);
			availableLanguages.push(fr_BE);
			availableLanguages.push(fr_CA);
			availableLanguages.push(fr_FR);
			availableLanguages.push(fr_LU);
			availableLanguages.push(fr_MC);
			availableLanguages.push(fr_CH);
			availableLanguages.push(gl_ES);
			availableLanguages.push(ka_GE);
			availableLanguages.push(de_AT);
			availableLanguages.push(de_DE);
			availableLanguages.push(de_LI);
			availableLanguages.push(de_LU);
			availableLanguages.push(de_CH);
			availableLanguages.push(el_GR);
			//		availableLanguages.push(gu_IN);
			//		availableLanguages.push(he_IL);
			//		availableLanguages.push(hi_IN);
			availableLanguages.push(hu_HU);
			availableLanguages.push(is_IS);
			//		availableLanguages.push(id_ID);
			availableLanguages.push(it_IT);
			availableLanguages.push(it_CH);
			//		availableLanguages.push(ja_JP);
			//		availableLanguages.push(kn_IN);
			//		availableLanguages.push(kk_KZ);	
			//		availableLanguages.push(ko_KR);	
			//		availableLanguages.push(ky_KG);	
			availableLanguages.push(lv_LV);	
			availableLanguages.push(lt_LT);
			//		availableLanguages.push(mk_MK);
			//		availableLanguages.push(ms_BN);
			//		availableLanguages.push(ms_MY);
			//		availableLanguages.push(mr_IN);
			//		availableLanguages.push(mn_MN);
			availableLanguages.push(nb_NO);
			availableLanguages.push(nn_NO);
			availableLanguages.push(pl_PL);
			availableLanguages.push(pt_BR);
			availableLanguages.push(pt_PT);
			//		availableLanguages.push(pa_IN);
			availableLanguages.push(ro_RO);
			availableLanguages.push(ru_RU);
			//		availableLanguages.push(sa_IN);
			availableLanguages.push(sr_SP);
			availableLanguages.push(sk_SK);
			availableLanguages.push(sl_SI);
			availableLanguages.push(es_AR);
			availableLanguages.push(es_BO);
			availableLanguages.push(es_CL);
			availableLanguages.push(es_CO);
			availableLanguages.push(es_CU);
			availableLanguages.push(es_CR);
			availableLanguages.push(es_DO);
			availableLanguages.push(es_EC);
			availableLanguages.push(es_SV);
			availableLanguages.push(es_GT);
			availableLanguages.push(es_HN);
			availableLanguages.push(es_MX);
			availableLanguages.push(es_NI);
			availableLanguages.push(es_PA);
			availableLanguages.push(es_PY);
			availableLanguages.push(es_PE);
			availableLanguages.push(es_PR);
			availableLanguages.push(es_ES);
			availableLanguages.push(es_UY);
			availableLanguages.push(es_VE);
			//		availableLanguages.push(sw_KE);
			availableLanguages.push(sv_FI);
			availableLanguages.push(sv_SE);
			//		availableLanguages.push(ta_IN);
			//		availableLanguages.push(tt_RU);
			//		availableLanguages.push(te_IN);
			//		availableLanguages.push(th_TH);
			availableLanguages.push(tr_TR);
			availableLanguages.push(uk_UA);
			//		availableLanguages.push(ur_PK);
			//		availableLanguages.push(uz_UZ);
			//		availableLanguages.push(vi_VN);
			
			
			for each(var code:String in ResourceManager.getInstance().getLocales()){
				guiLanguages.push(getLocaleAndFlagGivenLocaleCode(code));
			}
		}

		public function getLocaleAndFlagGivenLocaleCode(code:String):Object
		{
			var localeAndFlag:Object = null;
			for each(var language:Object in availableLanguages){
				if(language.code == code){
					localeAndFlag = language;
					break;
				}
			}
			return localeAndFlag;
		}
		
		public function getLevelCorrespondence(avgDifficulty:Number):String
		{
			var numFormat:NumberFormatter=new NumberFormatter();
			numFormat.precision=0;
			numFormat.rounding=NumberBaseRoundType.NEAREST;
			var roundedAvgDifficulty:int=int(numFormat.format(avgDifficulty));
			switch (roundedAvgDifficulty)
			{
				case 1:
					return 'A1';
					break;
				case 2:
					return 'A2';
					break;
				case 3:
					return 'B1';
					break;
				case 4:
					return 'B2';
					break;
				case 5:
					return 'C1';
					break;
				default:
					return '';
					break;
			}
		}

	}
}
