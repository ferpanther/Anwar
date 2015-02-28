package com
{
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.net.*;
	import fl.transitions.*;
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import fl.motion.*;
	import flash.display.BitmapData;
	import flash.text.TextField;


	public class AmfPhp extends MovieClip
	{
		protected var gw:NetConnection = new NetConnection();
		public static const PARAMS_LOADED:String = "params_loaded";
		public static const PARAMS_NOTLOADED:String = "params_notloaded";
		public static const PARAMS_SAVED:String = "params_saved";
		public static const PARAMS_NOTSAVED:String = "params_notsaved";


		public static const MODULES_LOADED:String = "modules_loaded";
		public static const MODULES_NOTLOADED:String = "modules_notloaded";
		public static const MODULE_SAVED:String = "module_saved";
		public static const MODULE_NOTSAVED:String = "module_notsaved";
		public static const MODULE_DELETED:String = "module_deleted";
		public static const MODULE_NOTDELETED:String = "module_notdeleted";

		public static const SALLES_LOADED:String = "salles_loaded";
		public static const SALLES_NOTLOADED:String = "salles_notloaded";
		public static const SALLE_SAVED:String = "salle_saved";
		public static const SALLE_NOTSAVED:String = "salle_notsaved";
		public static const SALLE_DELETED:String = "salle_deleted";
		public static const SALLE_NOTDELETED:String = "salle_notdeleted";

		public static const GROUPES_LOADED:String = "groupes_loaded";
		public static const GROUPES_NOTLOADED:String = "groupes_notloaded";
		public static const GROUPE_SAVED:String = "groupe_saved";
		public static const GROUPE_NOTSAVED:String = "groupe_notsaved";
		public static const GROUPE_DELETED:String = "groupe_deleted";
		public static const GROUPE_NOTDELETED:String = "groupe_notdeleted";

		

		public static const PERSONNEL_LOADED:String = "personnel_loaded";
		public static const PERSONNEL_NOTLOADED:String = "personnel_notloaded";

		public static const AGENT_SAVED:String = "agent_saved";
		public static const AGENT_NOTSAVED:String = "agent_notsaved";
		public static const AGENT_DELETED:String = "agent_deleted";
		public static const AGENT_NOTDELETED:String = "agent_notdeleted";
		
		public static const GARDIENS_LOADED:String = "gardiens_loaded";
		public static const GARDIENS_NOTLOADED:String = "gardiens_notloaded";
		public static const GARDIEN_SAVED:String = "gardien_saved";
		public static const GARDIEN_NOTSAVED:String = "gardien_notsaved";
		public static const GARDIEN_DELETED:String = "gardien_deleted";
		public static const GARDIEN_NOTDELETED:String = "gardien_notdeleted";
		
		public static const FEMMES_LOADED:String = "femmes_loaded";
		public static const FEMMES_NOTLOADED:String = "femmes_notloaded";
		public static const FEMME_SAVED:String = "femme_saved";
		public static const FEMME_NOTSAVED:String = "femme_notsaved";
		public static const FEMME_DELETED:String = "femme_deleted";
		public static const FEMME_NOTDELETED:String = "femme_notdeleted";

		public static const CADRES_LOADED:String = "cadres_loaded";
		public static const CADRES_NOTLOADED:String = "cadres_notloaded";

		public static const CADRE_SAVED:String = "cadre_saved";
		public static const CADRE_NOTSAVED:String = "cadre_notsaved";
		public static const CADRE_DELETED:String = "cadre_deleted";
		public static const CADRE_NOTDELETED:String = "cadre_notdeleted";

		public static const FICHESPF_LOADED:String = "fichespf_loaded";
		public static const FICHESPF_NOTLOADED:String = "fichespf_notloaded";

		public static const FICHESPA_LOADED:String = "fichespa_loaded";
		public static const FICHESPA_NOTLOADED:String = "fichespa_notloaded";
		
		public static const FICHESPG_LOADED:String = "fichespg_loaded";
		public static const FICHESPG_NOTLOADED:String = "fichespg_notloaded";
		
		public static const FICHESPW_LOADED:String = "fichespw_loaded";
		public static const FICHESPW_NOTLOADED:String = "fichespw_notloaded";

		public static const EMPLOI_LOADED:String = "emploi_loaded";
		public static const EMPLOI_NOTLOADED:String = "emploi_notloaded";

		public static const USER_TRUE:String = "user_true";
		public static const USER_FALSE:String = "user_false";
		public static const CONNEXION_ERROR:String = "connexion_error";


		public var params_xml:XML;
		public var items_xml:XML;
		public var modules_xml:XML;
		public var salles_xml:XML;
		public var groupes_xml:XML;
		private var cat:String;

		public function AmfPhp()
		{
			gw.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			gw.connect("http://www.flash-experts.com/amfphp/gateway.php");
		}

		private function netStatusHandler(event:NetStatusEvent):void
		{
			trace("=======", event.info.code);
			switch (event.info.code)
			{
				case "NetConnection.Call.Failed" :
					trace("CONNEXION ERROR!");
					break;
				case "NetConnection.Call.BadVersion" :
					trace("BadVersion ERROR!");
					break;
				default :
					trace("default ERROR");
			}
		}
		//----------------------------------------------------------------
		public function sendMail(from:String, to:String, subject:String, msg:String):void
		{
			var email_sender:Responder = new Responder(onEmailSentResult,onEmailSentFault);
			gw.call("Mail.send", email_sender, from, to, subject, msg);
		}
		//----------------------------------------------------------------------------
		protected function onEmailSentFault(reponse:Object):void
		{
			trace("onEmailSentFault", reponse);
			trace("CONNEXION ERROR!");
		}
		//----------------------------------------------------------------------------
		protected function onEmailSentResult(reponse:Object):void
		{
			if (reponse)
			{
				trace("EMAIL SENT.");
			}
			else
			{
				trace("CONNEXION ERROR, PLEASE TRY AGAIN!");
			}
		}
		//-----------------------------------------------------------------------------------------------------
		public function checkUser(user:String, pass:String):void
		{
			var login_responder:Responder = new Responder(onloginResult,onloginFault);
			gw.call("Anwar.check", login_responder, user, pass);
		}
		//----------------------------------------------------------------------------------------
		function onloginResult(reponse:Object):void
		{
			var t:Array = reponse.serverInfo.initialData;
			if (t.length > 0)
			{
				dispatchEvent(new Event(AmfPhp.USER_TRUE));
			}
			else
			{
				dispatchEvent(new Event(AmfPhp.USER_FALSE));
			}
		}
		//----------------------------------------------------------------------------------------
		function onloginFault(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.CONNEXION_ERROR));
		}
		//-----------------------------------------------------------------------------------------
		public function saveParams(cat:String, paramsA:String, paramsF:String):void
		{
			var params_responder:Responder = new Responder(onSaveParamsResult,onSaveParamsFault);
			gw.call("Anwar.saveParams", params_responder, cat, paramsA, paramsF);
		}
		//----------------------------------------------------------------------------------------
		function onSaveParamsResult(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.PARAMS_SAVED));
		}
		//----------------------------------------------------------------------------------------
		function onSaveParamsFault(reponse:Object):void
		{
			trace(reponse);
			dispatchEvent(new Event(AmfPhp.PARAMS_NOTSAVED));
		}
		//-----------------------------------------------------------------------------------------
		public function getParams():void
		{
			var params_responder:Responder = new Responder(onGetParamsResult,onGetParamsFault);
			gw.call("Anwar.getParams", params_responder);
		}
		//----------------------------------------------------------------------------------------
		function onGetParamsResult(reponse:Object):void
		{
			params_xml = new XML(reponse);
			dispatchEvent(new Event(AmfPhp.PARAMS_LOADED));
		}
		//----------------------------------------------------------------------------------------
		function onGetParamsFault(reponse:Object):void
		{
			trace(reponse);
			params_xml = new XML(reponse);
			dispatchEvent(new Event(AmfPhp.PARAMS_NOTLOADED));
		}
		//------------------------------------------------
		public function loadModules():void
		{
			var modules_responder:Responder = new Responder(onLoadModulesResult,onLoadModulesFault);
			gw.call("Anwar.getModules", modules_responder);
		}
		//------------------------------------------------
		private function onLoadModulesResult(reponse:Object):void
		{
			modules_xml = new XML(reponse);
			dispatchEvent(new Event(AmfPhp.MODULES_LOADED));
		}
		//------------------------------------------------
		private function onLoadModulesFault(reponse:Object):void
		{
			trace("Échec de lecture.");
			dispatchEvent(new Event(AmfPhp.MODULES_NOTLOADED));
		}
		//------------------------------------------------
		public function loadGroupes():void
		{
			var modules_responder:Responder = new Responder(onLoadGroupesResult,onLoadGroupesFault);
			gw.call("Anwar.getGroupes", modules_responder);
		}
		//------------------------------------------------
		private function onLoadGroupesResult(reponse:Object):void
		{
			groupes_xml = new XML(reponse);
			dispatchEvent(new Event(AmfPhp.GROUPES_LOADED));
		}
		//------------------------------------------------
		private function onLoadGroupesFault(reponse:Object):void
		{
			trace("Échec de lecture.");
			dispatchEvent(new Event(AmfPhp.GROUPES_NOTLOADED));
		}
		//------------------------------------------------
		public function loadSalles():void
		{
			var modules_responder:Responder = new Responder(onLoadSallesResult,onLoadSallesFault);
			gw.call("Anwar.getSalles", modules_responder);
		}
		//------------------------------------------------
		private function onLoadSallesResult(reponse:Object):void
		{
			salles_xml = new XML(reponse);
			dispatchEvent(new Event(AmfPhp.SALLES_LOADED));
		}
		//------------------------------------------------
		private function onLoadSallesFault(reponse:Object):void
		{
			trace("Échec de lecture.");
			dispatchEvent(new Event(AmfPhp.SALLES_NOTLOADED));
		}
		//------------------------------------------------
		public function saveModules(nom:String):void
		{
			var modules_responder:Responder = new Responder(onSaveModulesResult,onSaveModulesError);
			gw.call("Anwar.addModules", modules_responder, nom);
		}
		//------------------------------------------------
		private function onSaveModulesResult(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.MODULE_SAVED));
		}
		//------------------------------------------------
		private function onSaveModulesError(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.MODULE_NOTSAVED));
		}
		//------------------------------------------------
		public function saveGroupes(nom:String):void
		{
			var groupes_responder:Responder = new Responder(onSaveGroupesResult,onSaveGroupesError);
			gw.call("Anwar.addGroupes", groupes_responder, nom);
		}
		//------------------------------------------------
		private function onSaveGroupesResult(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.GROUPE_SAVED));
		}
		//------------------------------------------------
		private function onSaveGroupesError(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.GROUPE_NOTSAVED));
		}
		//------------------------------------------------
		public function saveSalles(nom:String):void
		{
			var salles_responder:Responder = new Responder(onSaveSallesResult,onSaveSallesError);
			gw.call("Anwar.addSalles", salles_responder, nom);
		}
		//------------------------------------------------
		private function onSaveSallesResult(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.SALLE_SAVED));
		}
		//------------------------------------------------
		private function onSaveSallesError(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.SALLE_NOTSAVED));
		}
		//------------------------------------------------
		public function deleteModule(nom:String):void
		{
			var delete_responder:Responder = new Responder(onDeleteModuleResult,onDeleteModuleFault);
			gw.call("Anwar.deleteModule", delete_responder, nom);
		}
		//------------------------------------------------
		private function onDeleteModuleResult(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.MODULE_DELETED));
		}
		//------------------------------------------------
		private function onDeleteModuleFault(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.MODULE_NOTDELETED));
		}
		//------------------------------------------------
		public function deleteGroupe(nom:String):void
		{
			var delete_responder:Responder = new Responder(onDeleteGroupeResult,onDeleteGroupeFault);
			gw.call("Anwar.deleteGroupe", delete_responder, nom);
		}
		//------------------------------------------------
		private function onDeleteGroupeResult(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.GROUPE_DELETED));
		}
		//------------------------------------------------
		private function onDeleteGroupeFault(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.GROUPE_NOTDELETED));
		}
		//------------------------------------------------
		public function deleteSalle(nom:String):void
		{
			var delete_responder:Responder = new Responder(onDeleteSalleResult,onDeleteSalleFault);
			gw.call("Anwar.deleteSalle", delete_responder, nom);
		}
		//------------------------------------------------
		private function onDeleteSalleResult(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.SALLE_DELETED));
		}
		//------------------------------------------------
		private function onDeleteSalleFault(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.SALLE_NOTDELETED));
		}
		//-----------------------------------
		public function loadAgents(php_load:String):void
		{
			var get_responder:Responder = new Responder(onGetPersResult,onGetPersFault);
			gw.call(php_load, get_responder);
		}
		//-----------------------------------
		private function onGetPersResult(reponse:Object):void
		{
			items_xml = new XML(reponse);
			dispatchEvent(new Event(AmfPhp.PERSONNEL_LOADED));
		}
		//-----------------------------------
		private function onGetPersFault(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.PERSONNEL_NOTLOADED));
		}
		//------------------------------------------------
		public function savePersonnel(php_save:String, uid:String, nom:String, prenom:String):void
		{
			var personnel_responder:Responder = new Responder(onSavePersResult,onSavePersError);
			gw.call(php_save, personnel_responder,  uid, nom, prenom);
		}
		//------------------------------------------------
		private function onSavePersResult(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.AGENT_SAVED));
		}
		//------------------------------------------------
		private function onSavePersError(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.AGENT_NOTSAVED));
		}
		//------------------------------------------------
		public function deleteAgent(php_delete, nom:String):void
		{
			var delete_responder:Responder = new Responder(onDeleteAgentResult,onDeleteAgentFault);
			gw.call(php_delete, delete_responder, nom);
		}
		//------------------------------------------------
		private function onDeleteAgentResult(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.AGENT_DELETED));
		}
		//------------------------------------------------
		private function onDeleteAgentFault(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.AGENT_NOTDELETED));
		}
		//-----------------------------------
		public function loadGardiens(php_load:String):void
		{
			var get_responder:Responder = new Responder(onGetGardienResult,onGetGardienFault);
			gw.call(php_load, get_responder);
		}
		//-----------------------------------
		private function onGetGardienResult(reponse:Object):void
		{
			items_xml = new XML(reponse);
			dispatchEvent(new Event(AmfPhp.GARDIENS_LOADED));
		}
		//-----------------------------------
		private function onGetGardienFault(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.GARDIENS_NOTLOADED));
		}
		//------------------------------------------------
		public function saveGardiens(php_save:String, uid:String, nom:String, prenom:String, post:String):void
		{
			var personnel_responder:Responder = new Responder(onSaveGardiensResult,onSaveGardiensError);
			gw.call(php_save, personnel_responder,  uid, nom, prenom, post);
		}
		//------------------------------------------------
		private function onSaveGardiensResult(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.GARDIEN_SAVED));
		}
		//------------------------------------------------
		private function onSaveGardiensError(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.GARDIEN_NOTSAVED));
		}
		//------------------------------------------------
		public function deleteGardiens(php_delete, nom:String):void
		{
			var delete_responder:Responder = new Responder(onDeleteGardienResult,onDeleteGardienFault);
			gw.call(php_delete, delete_responder, nom);
		}
		//------------------------------------------------
		private function onDeleteGardienResult(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.GARDIEN_DELETED));
		}
		//------------------------------------------------
		private function onDeleteGardienFault(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.GARDIEN_NOTDELETED));
		}
		//-----------------------------------
		public function loadFemmes(php_load:String):void
		{
			var get_responder:Responder = new Responder(onGetFemmeResult,onGetFemmeFault);
			gw.call(php_load, get_responder);
		}
		//-----------------------------------
		private function onGetFemmeResult(reponse:Object):void
		{
			items_xml = new XML(reponse);
			dispatchEvent(new Event(AmfPhp.FEMMES_LOADED));
		}
		//-----------------------------------
		private function onGetFemmeFault(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.FEMMES_NOTLOADED));
		}
		//------------------------------------------------
		public function saveFemmes(php_save:String, uid:String, nom:String, prenom:String):void
		{
			var femmes_responder:Responder = new Responder(onSaveFemmesResult,onSaveFemmesError);
			gw.call(php_save, femmes_responder,  uid, nom, prenom);
		}
		//------------------------------------------------
		private function onSaveFemmesResult(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.FEMME_SAVED));
		}
		//------------------------------------------------
		private function onSaveFemmesError(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.FEMME_NOTSAVED));
		}
		//------------------------------------------------
		public function deleteFemmes(php_delete, nom:String):void
		{
			var delete_responder:Responder = new Responder(onDeleteFemmeResult,onDeleteFemmeFault);
			gw.call(php_delete, delete_responder, nom);
		}
		//------------------------------------------------
		private function onDeleteFemmeResult(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.FEMME_DELETED));
		}
		//------------------------------------------------
		private function onDeleteFemmeFault(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.FEMME_NOTDELETED));
		}
		//-----------------------------------
		public function loadCadres(php_load:String):void
		{
			var get_responder:Responder = new Responder(onGetCadresResult,onGetCadresFault);
			gw.call(php_load, get_responder);
		}
		//-----------------------------------
		private function onGetCadresResult(reponse:Object):void
		{
			items_xml = new XML(reponse);
			dispatchEvent(new Event(AmfPhp.CADRES_LOADED));
		}
		//-----------------------------------
		private function onGetCadresFault(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.CADRES_NOTLOADED));
		}
		//------------------------------------------------
		public function saveCadre(php_save:String, uid:String, nom:String, prenom:String, matiere:String, horaire:String):void
		{
			var cadre_responder:Responder = new Responder(onSaveCadreResult,onSaveCadreError);
			gw.call(php_save, cadre_responder,  uid, nom, prenom, matiere, horaire);
		}
		//------------------------------------------------
		private function onSaveCadreResult(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.CADRE_SAVED));
		}
		//------------------------------------------------
		private function onSaveCadreError(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.CADRE_NOTSAVED));
		}
		//------------------------------------------------
		public function deleteCadre(php_delete, uid:String):void
		{
			var delete_responder:Responder = new Responder(onDeleteCadreResult,onDeleteCadreFault);
			gw.call(php_delete, delete_responder, uid);
		}
		//------------------------------------------------
		private function onDeleteCadreResult(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.CADRE_DELETED));
		}
		//------------------------------------------------
		private function onDeleteCadreFault(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.CADRE_NOTDELETED));
		}
		//-----------------------------------
		public function loadFichesPF(php_path:String, year:int):void
		{
			var get_responder:Responder = new Responder(onLoadFichesPFResult,onLoadFichesPFError);
			gw.call(php_path, get_responder, year);
		}
		//-----------------------------------
		private function onLoadFichesPFResult(reponse:Object):void
		{
			items_xml = new XML(reponse);
			dispatchEvent(new Event(AmfPhp.FICHESPF_LOADED));
		}
		//-----------------------------------
		private function onLoadFichesPFError(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.FICHESPF_NOTLOADED));
		}
		//-----------------------------------
		public function loadFichesPA(php_path:String, year:int):void
		{
			var get_responder:Responder = new Responder(onLoadFichesPAResult,onLoadFichesPAError);
			gw.call(php_path, get_responder, year);
		}
		//-----------------------------------
		private function onLoadFichesPAResult(reponse:Object):void
		{
			items_xml = new XML(reponse);
			dispatchEvent(new Event(AmfPhp.FICHESPA_LOADED));
		}
		//-----------------------------------
		private function onLoadFichesPAError(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.FICHESPA_NOTLOADED));
		}
		//-----------------------------------
		public function loadFichesPG(php_path:String, year:int):void
		{
			var get_responder:Responder = new Responder(onLoadFichesPGResult,onLoadFichesPGError);
			gw.call(php_path, get_responder, year);
		}
		//-----------------------------------
		private function onLoadFichesPGResult(reponse:Object):void
		{
			items_xml = new XML(reponse);
			dispatchEvent(new Event(AmfPhp.FICHESPG_LOADED));
		}
		//-----------------------------------
		private function onLoadFichesPGError(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.FICHESPG_NOTLOADED));
		}
		//-----------------------------------
		public function loadFichesPW(php_path:String, year:int):void
		{
			var get_responder:Responder = new Responder(onLoadFichesPWResult,onLoadFichesPWError);
			gw.call(php_path, get_responder, year);
		}
		//-----------------------------------
		private function onLoadFichesPWResult(reponse:Object):void
		{
			items_xml = new XML(reponse);
			dispatchEvent(new Event(AmfPhp.FICHESPW_LOADED));
		}
		//-----------------------------------
		private function onLoadFichesPWError(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.FICHESPW_NOTLOADED));
		}
		//-----------------------------------
		public function loadEmploi(php_path:String):void
		{
			var get_responder:Responder = new Responder(onGetEmploiResult,onGetEmploiFault);
			gw.call(php_path, get_responder);
		}
		//-----------------------------------
		private function onGetEmploiResult(reponse:Object):void
		{
			items_xml = new XML(unescape(reponse.toString()));
			dispatchEvent(new Event(AmfPhp.EMPLOI_LOADED));
		}
		//-----------------------------------
		private function onGetEmploiFault(reponse:Object):void
		{
			dispatchEvent(new Event(AmfPhp.EMPLOI_NOTLOADED));
		}
		//----------------------------------------------------------------------------
	}
}