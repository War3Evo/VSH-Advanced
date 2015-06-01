// vsha_Engine_SubPlugin_Configuration_File.inc



enum VSHA_SoundType
{
	VSHA_none,
	VSHA_Sounds,
	VSHA_Materials,
	VSHA_Models,
	VSHA_Misc
}

VSHA_SoundType VSHA_Load_Type = VSHA_none;

public bool VSHA_Load_Configuration(Handle plugin, char[] cFileName)
{
	bool found = false;

	Handle kv = PrePareTheFile(cFileName);

	if(kv != null)
	{
		// VSHA_OnConfiguration_Load_*(char[] key, char[] value)

		found = LoadConfigurationValues(cFileName, kv, plugin);
		CloseTheFile(kv);
		return found;
	}
	return false;
}

public Handle PrePareTheFile(char[] cfile)
{
	char path[1024];

	//"configs/sb_weapons.cfg" = cfile
	BuildPath(Path_SM,path,sizeof(path),cfile);

	/* Return true if an update was available. */
	// "TF2_SB_WEAPONS" = cName
	Handle kv = CreateKeyValues("VSHA_CONFIGURATION");

	if (!FileToKeyValues(kv, path))
	{
		CloseHandle(kv);
		return null;
	}
	return kv;
}

public void CloseTheFile(Handle kv)
{
	CloseHandle(kv);
}


public bool LoadConfigurationValues(char[] cfile, Handle kv, Handle plugin)
{
	KvRewind(kv);

	//bool result = false;

	char sSectionBuffer[32];
	char sSubKeyBuffer[32];

	char sTempBuffer[PATHX];

	bool found=false;

	bool bPreCacheFile = false;
	bool bAddFileToDownloadsTable = false;
	bool bPreCacheFile2 = false;
	bool bAddFileToDownloadsTable2 = false;
	bool bPreCacheFile3 = false;
	bool bAddFileToDownloadsTable3 = false;

	do
	{
		// You can read the section/key name by using KvGetSectionName here.
		//PrintToChatAll("do loop\n");

		if (KvGotoFirstSubKey(kv, false))
		{
			do
			{
				if(KvGetSectionName(kv, sSectionBuffer, sizeof(sSectionBuffer)))
				{
					PrintToServer("LOADING: %s",sSectionBuffer);
					if(StrContains(sSectionBuffer,"sound",false) == 0)
					{
						VSHA_Load_Type = VSHA_Sounds;
					}
					else if(StrContains(sSectionBuffer,"material",false) == 0)
					{
						VSHA_Load_Type = VSHA_Materials;
					}
					else if(StrContains(sSectionBuffer,"model",false) == 0)
					{
						VSHA_Load_Type = VSHA_Models;
					}
					else if(StrContains(sSectionBuffer,"misc",false) == 0)
					{
						VSHA_Load_Type = VSHA_Misc;
					}
					else
					{
						continue;
					}

					//PushArrayCell(g_hItemNumber, GetArraySize(g_hItemNumber)+1);

					if (KvGotoFirstSubKey(kv, false))
					{
						// Current key is a section. Browse it recursively.
						do
						{
							if(KvGetSectionName(kv, sSubKeyBuffer, sizeof(sSubKeyBuffer)))
							{
								KvGetString(kv, NULL_STRING, sTempBuffer, sizeof(sTempBuffer));
								if(VSHA_Load_Type == VSHA_Sounds)
								{
										TrimString(sSubKeyBuffer);
										TrimString(sTempBuffer);
										bPreCacheFile = false;
										bAddFileToDownloadsTable = false;

										INTERNAL_VSHA_OnConfiguration_Load_Sounds(cfile, sSubKeyBuffer, sTempBuffer, bPreCacheFile, bAddFileToDownloadsTable);

										if(bPreCacheFile)
										{
											PrecacheSound(sTempBuffer,true);
										}
										if(bAddFileToDownloadsTable)
										{
											char sFileNameAndPath[PATHX];
											Format(STRING(sFileNameAndPath), "sound/%s", sTempBuffer);
											AddFileToDownloadsTable(sFileNameAndPath);
										}

										found = true;
								}
								else if(VSHA_Load_Type == VSHA_Materials)
								{
										TrimString(sSubKeyBuffer);
										TrimString(sTempBuffer);
										bPreCacheFile2 = false;
										bAddFileToDownloadsTable2 = false;

										INTERNAL_VSHA_OnConfiguration_Load_Materials(cfile, sSubKeyBuffer, sTempBuffer, bPreCacheFile2, bAddFileToDownloadsTable2);

										if(bPreCacheFile2)
										{
											PrecacheGeneric(sTempBuffer,true);
										}
										if(bAddFileToDownloadsTable2)
										{
											AddFileToDownloadsTable(sTempBuffer);
										}

										found = true;
								}
								else if(VSHA_Load_Type == VSHA_Models)
								{
										TrimString(sSubKeyBuffer);
										TrimString(sTempBuffer);
										bPreCacheFile3 = false;
										bAddFileToDownloadsTable3 = false;

										INTERNAL_VSHA_OnConfiguration_Load_Models(cfile, sSubKeyBuffer, sTempBuffer, bPreCacheFile3, bAddFileToDownloadsTable3);

										if(bPreCacheFile3)
										{
											PrecacheModel(sTempBuffer,true);
										}
										if(bAddFileToDownloadsTable3)
										{
											AddFileToDownloadsTable(sTempBuffer);
										}

										found = true;
								}
								else if(VSHA_Load_Type == VSHA_Misc)
								{
										INTERNAL_VSHA_OnConfiguration_Load_Misc(cfile, sSubKeyBuffer, sTempBuffer);

										found = true;
								}
							}
						} while (KvGotoNextKey(kv, false));
						KvGoBack(kv);
					}
				}
			} while (KvGotoNextKey(kv, false));
			KvGoBack(kv);
		}
	} while (KvGotoNextKey(kv, false));

	//PrintToChatAll("Finished");
	return found;
}
