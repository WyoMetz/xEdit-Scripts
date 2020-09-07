
{
    Purpose: Generates Load Order Specific Default lists for Assinged Storage.
    Game: The Elder Scrolls V: Skyrim
    Author: Whiskey Metz <WhiskeyMetz@gmail.com>
    Version: 1.0
    Usage: Apply Script to Entire load Order and Write result to 
      *SkyrimSE*\Data\SKSE\plugins\JCData\Domains\phiASDomain
}

Unit UserScript; 

var 
  formIds: THashedStringList;
  lightArmor,
  heavyArmor,
  shields,
  oneHanded,
  twoHanded,
  bow,
  staff,
  jewelery,
  clothesBody,
  clothesChildren,
  clothesHandFeet,
  potionsPoisons,
  potionsBeneficial,
  foodItem,
  foodIngredient,
  ingredient,
  spellTomes,
  books,
  scrolls,
  keys,
  oreAndIngots,
  gems,
  skinBoneLeather,
  clutter,
  treasures,
  homeItems : TStringList;
  i : integer;
  verboseLogging, logDump : boolean;
  saveLocation : string;

Function Initialize(): integer;
  Begin
    ClearMessages();
    saveLocation := SelectDirectory('You are looking for Data\SKSE\plugins\JCData\Domains\phiASDomain', DataPath, '', '');
    If (Length(saveLocation) = 0) Then
      Begin
        AddMessage('Canceled By User. Exiting Script');
        Result := 1;
        exit;
      End;
    AddMessage('Location Saved. Beginning Script. Please Wait....');
    verboseLogging := true;
    logDump := false;
    formIds := THashedStringList.Create;
    lightArmor := TStringList.Create;
    heavyArmor := TStringList.Create;
    shields := TStringList.Create;
    oneHanded := TStringList.Create;
    twoHanded := TStringList.Create;
    bow := TStringList.Create;
    staff := TStringList.Create;
    jewelery := TStringList.Create;
    clothesBody := TStringList.Create;
    clothesChildren := TStringList.Create;
    clothesHandFeet := TStringList.Create;
    potionsPoisons := TStringList.Create;
    potionsBeneficial := TStringList.Create;
    foodItem := TStringList.Create;
    foodIngredient := TStringList.Create;
    ingredient := TStringList.Create;
    spellTomes := TStringList.Create;
    books := TStringList.Create;
    scrolls := TStringList.Create;
    keys := TStringList.Create;
    oreAndIngots := TStringList.Create;
    gems := TStringList.Create;
    skinBoneLeather := TStringList.Create;
    clutter := TStringList.Create;
    treasures := TStringList.Create;
    homeItems := TStringList.Create;
    Result := 0;
  End;

Function VerifyNewRecord(modRecord: IInterface): integer; 
  var 
    recordName, formId: string;
    i : integer;
  Begin
    recordName := Name(modRecord);
    formId := IntToHex(FixedFormID(modRecord), 5);
    If (formIds.IndexOf(formID) > -1) Then
      Begin
        AddMessage('Found Duplicate -- ' + recordName);
        Result := 0;
        exit;
      End;
    formIds.Add(formId);
    Result := 1;
  End;

Function BaseRecordData(modRecord: IInterface): String; 
  var 
    recordName, formId : String;
  Begin
    recordName := GetFileName(modRecord);
    formId := '0x' + IntToHex(FixedFormID(modRecord),5);
    Result := '"__formData|' + recordName + '|' + formId + '",';
  End;

Function FindKeyword(keywords: IInterface; keyword: String): integer; 
  var 
    itemList : IInterface; 
  var 
    keywordResult : string; 
  var 
    i : integer;
  Begin
    If ElementCount(keywords) > 0 Then
      Begin
        For i := 0 To ElementCount(keywords) -  1 Do
          Begin
            itemList := LinksTo(ElementByIndex(keywords, i));
            keywordResult := GetEditValue(ElementBySignature(itemList, 'EDID'));
            If (keywordResult = keyword) Then
              Result := 1;
            exit;
          End;
      End;
  End;

Function LogMessage(modRecord: IInterface; category: String): integer;
  Begin
    If (verboseLogging = true) Then
      Begin
        AddMessage(Name(modRecord) + ' Added to ' + category);
      End;
  End;

Function DumpToLog(list : TStringList): integer; 
  var 
    i : integer;
  Begin
    If (logDump = true) Then
      Begin
        For i := 0 To list.Count -1 Do
          Begin
            AddMessage(list[i]);
          End;
      End;
  End;

Function WriteToFile(list: TStringList; fileName: String): integer; 
  var 
    lastString : string; 
  var 
    stringPosition: integer;
  Begin
    list.Insert(0, '[');
    stringPosition := List.Count -1;
    lastString := list[stringPosition];
    list.Delete(stringPosition);
    Delete(lastString, Length(lastString), 4);
    list.Add(lastString);
    list.Add(']');
    If (Length(saveLocation) > 0) Then
      Begin
        list.SaveToFile(saveLocation + '\' + fileName)
      End
    Else
      AddMessage('Canceled writing to file.');
  End;

Function RunWeaponRecord(modRecord : IInterface): integer; 
  var 
    weaponType : string;
    overrideRecord : IInterface;
  Begin
    overrideRecord := WinningOverride(modRecord);
    weaponType := GetElementEditValues(overrideRecord, 'DNAM\Animation Type');
    If pos('TwoHand', weaponType) > 0 Then
      Begin
        twoHanded.Add(BaseRecordData(modRecord));
        LogMessage(modRecord, 'Two Handed Weapons');
        exit;
      End;
    If pos('OneHand', weaponType) > 0 Then
      Begin
        oneHanded.Add(BaseRecordData(modRecord));
        LogMessage(modRecord, 'One Handed Weapons');
        exit;
      End;
    If pos('Bow', weaponType) > 0 Then
      Begin
        bow.Add(BaseRecordData(modRecord));
        LogMessage(modRecord, 'Bows');
        exit;
      End;
    If pos('Staff', weaponType) > 0 Then
      Begin
        staff.Add(BaseRecordData(modRecord));
        LogMessage(modRecord, 'Staff');
        exit;
      End;
  End;

Function RunClothesRecord(modRecord: IInterface): integer; 
  var 
    edid : string; 
  var 
    gloves, boots, amulets, rings, circlets, bodies : integer;
    overrideRecord : IInterface;
  Begin
    edid := GetEditValue(ElementBySignature(modRecord, 'EDID'));
    overrideRecord := WinningOverride(modRecord);
    gloves := GetElementEditValues(overrideRecord, 'BOD2\First Person Flags\33 - Hands');
    boots := GetElementEditValues(overrideRecord, 'BOD2\First Person Flags\37 - Feet');
    rings := GetElementEditValues(overrideRecord, 'BOD2\First Person Flags\36 - Ring');
    amulets := GetElementEditValues(overrideRecord, 'BOD2\First Person Flags\35 - Amulet');
    circlets := GetElementEditValues(overrideRecord, 'BOD2\First Person Flags\42 - Circlet');
    bodies := GetElementEditValues(overrideRecord, 'BOD2\First Person Flags\32 - Body');
    If (IntToHex(rings, 1) = '1') Or (IntToHex(amulets, 1) = '1') Or ((IntToHex(circlets, 1) = '1') And (IntToHex(bodies, 1) = '0')) Then
      Begin
        jewelery.Add(BaseRecordData(modRecord));
        LogMessage(modRecord, 'Valuables - Jewelery');
        exit;
      End;
    If pos('ClothesChild', edid) > 0 Then
      Begin
        clothesChildren.Add(BaseRecordData(modRecord));
        LogMessage(modRecord, 'Childrens Clothes');
        exit;
      End;
    If (IntToHex(gloves,1) = '1') Or (IntToHex(boots,1) = '1') Then
      Begin
        clothesHandFeet.Add(BaseRecordData(modRecord));
        LogMessage(modRecord, 'Clothes - Gloves/Shoes');
        exit;
      End;
    clothesBody.Add(BaseRecordData(modRecord));
    LogMessage(modRecord, 'Clothes');
  End;

Function RunAmmoRecord(modRecord: IInterface): integer; 
  var 
    isNotPlayable : string;
    overrideRecord : IInterface;
  Begin
    isNotPlayable := GetElementEditValues(overrideRecord, 'DATA\Flags\Non-Playable');
    If isNotPlayable = '1' Then
      Begin
        exit;
      End;
    bow.Add(BaseRecordData(modRecord));
    LogMessage(modRecord, 'Bows');
  End;

Function RunArmorRecord(modRecord : IInterface): integer; 
  var 
    armorType, etyp : string;
    overrideRecord : IInterface;
  Begin
    overrideRecord := WinningOverride(modRecord);
    armorType := GetElementEditValues(overrideRecord, 'BOD2\Armor Type');
    etyp := GetElementEditValues(overrideRecord, 'ETYP');
    If pos('Shield', etyp) > 0 Then
      Begin
        shields.Add(BaseRecordData(modRecord));
        LogMessage(modRecord, 'Shields');
        exit;
      End;
    If (armorType = 'Heavy Armor') Then
      Begin
        heavyArmor.Add(BaseRecordData(modRecord));
        LogMessage(modRecord, 'Heavy Armor');
        exit;
      End;
    If (armorType = 'Light Armor') Then
      Begin
        lightArmor.Add(BaseRecordData(modRecord));
        LogMessage(modRecord, 'Light Armor');
      End;
    If (armorType = 'Clothing') Then
      Begin
        RunClothesRecord(modRecord);
      End;
  End;

Function RunAlchRecord(modRecord: IInterface): integer; 
  var 
    foodKeyword, foodRawKeyword, potionKeyword, poisonKeyword: int; 
  var 
    keywordGroup, overrideRecord : IInterface; 
  var 
    foodFlag, poisonFlag : string;
  Begin
    overrideRecord := WinningOverride(modRecord);
    keywordGroup := ElementByName(overrideRecord, 'KWDA - Keywords');
    foodKeyword := FindKeyword(keywordGroup, 'VendorItemFood');
    foodRawKeyword := FindKeyword(keywordGroup, 'VendorItemFoodRaw');
    potionKeyword := FindKeyword(keywordGroup, 'VendorItemPotion');
    poisonKeyword := FindKeyword(keywordGroup, 'VendorItemPoison');
    foodFlag := GetElementEditValues(overrideRecord, 'ENIT\Flags\Food Item');
    poisonFlag := GetElementEditValues(overrideRecord, 'ENIT\Flags\Poison');
    If (poisonFlag = '1') Then
      Begin
        potionsPoisons.Add(BaseRecordData(modRecord));
        LogMessage(modRecord, 'Poisons');
        exit;
      End;
    If (foodFlag = '1') Then
      Begin
        foodItem.Add(BaseRecordData(modRecord));
        LogMessage(modRecord, 'Food');
        exit;
      End;
    If (foodRawKeyword = 1) Then
      Begin
        foodIngredient.Add(BaseRecordData(modRecord));
        LogMessage(modRecord, 'Food Ingredients');
        exit;
      End;
    If (foodKeyword = 1) Then
      Begin
        foodItem.Add(BaseRecordData(modRecord));
        LogMessage(modRecord, 'Food');
        exit;
      End;
    If (potionKeyword = 1) Then
      Begin
        potionsBeneficial.Add(BaseRecordData(modRecord));
        LogMessage(modRecord, 'Potions');
        exit;
      End;
    If (poisonKeyword = 1) Then
      Begin
        potionsPoisons.Add(BaseRecordData(modRecord));
        LogMessage(modRecord, 'Poisons');
        exit;
      End;
    potionsBeneficial.Add(BaseRecordData(modRecord));
    LogMessage(modRecord, 'Potions');
  End;

Function RunIngredientRecord(modRecord : IInterface): integer;
  Begin
    ingredient.Add(BaseRecordData(modRecord));
    LogMessage(modRecord, 'Ingredients');
  End;

Function RunMiscRecord(modRecord: IInterface): integer; 
  var 
    keywordGroup, overrideRecord : IInterface;
    OreIngot, clutterItem, tool, gem, animalHide, animalPart : integer;
  Begin
    overrideRecord := WinningOverride(modRecord);
    If (pos('Gold001', Name(modRecord)) > 0) Or (pos('Lockpick', Name(modRecord)) > 0) Or (pos('phiAS', Name(modRecord)) > 0) Then
      Begin
        AddMessage(Name(modRecord) + ' has been skipped');
        exit;
      End;
    If (pos('BYOH', Name(modRecord)) > 0)Then
      Begin
        homeItems.Add(BaseRecordData(modRecord));
        LogMessage(modRecord, 'Housing');
        exit;
      End;
    keywordGroup := ElementByName(overrideRecord, 'KWDA - Keywords');
    OreIngot := FindKeyword(keywordGroup, 'VendorItemOreIngot');
    If (OreIngot = 1)Then
      Begin
        oreAndIngots.Add(BaseRecordData(modRecord));
        LogMessage(modRecord, 'Ores and Ingots');
        exit;
      End;
    gem := FindKeyword(keywordGroup, 'VendorItemGem');
    If (gem = 1)Then
      Begin
        gems.Add(BaseRecordData(modRecord));
        LogMessage(modRecord, 'Gems');
        exit;
      End;
    animalHide := FindKeyword(keywordGroup, 'VendorItemAnimalHide');
    animalPart := FindKeyword(keywordGroup, 'VendorItemAnimalPart');
    If (animalHide = 1) Or (animalPart = 1)Then
      Begin
        skinBoneLeather.Add(BaseRecordData(modRecord));
        LogMessage(modRecord, 'Leather, Scale, and Bone ');
        exit;
      End;
    tool := FindKeyword(keywordGroup, 'VendorItemTool');
    clutterItem := FindKeyword(keywordGroup, 'VendorItemClutter');
    If (tool = 1) Or (clutterItem = 1)Then
      Begin
        clutter.Add(BaseRecordData(modRecord));
        LogMessage(modRecord, 'MISC - Random');
        exit;
      End;
    treasures.add(BaseRecordData(modRecord));
    LogMessage(modRecord, 'Valuables - Treasure');
  End;

Function RunBookRecord(modRecord: IInterface): integer; 
  var 
    spellFlag : string;
  Begin
    spellFlag := GetElementEditValues(WinningOverride(modRecord), 'DATA\Flags\Teaches Spell');
    If (spellFlag = '1') Then
      Begin
        spellTomes.Add(BaseRecordData(modRecord));
        LogMessage(modRecord, 'Spell Tomes');
        exit;
      End;
    books.Add(BaseRecordData(modRecord));
    LogMessage(modRecord, 'Books');
  End;

Function RunScrollRecord(modRecord: IInterface): integer;
  Begin
    scrolls.Add(BaseRecordData(modRecord));
    LogMessage(modRecord, 'Scrolls');
  End;

Function RunKeyRecord(modRecord: IInterface): integer;
  Begin
    keys.Add(BaseRecordData(modRecord));
    LogMessage(modRecord, 'Keys');
  End;

Function Process(e: IInterface): integer; 
  var 
    recordType: String;
  Begin
    recordType := Signature(e);
    If (recordType <> 'ARMO') And
       (recordType <> 'AMMO') And
       (recordType <> 'WEAP') And
       (recordType <> 'ALCH') And
       (recordType <> 'MISC') And
       (recordType <> 'BOOK') And
       (recordType <> 'INGR') And
       (recordType <> 'KEYM') And
       (recordType <> 'SCRL') Then
      Begin
        exit;
      End;
    If (recordType = 'ARMO') Then
      Begin
        RunArmorRecord(e);
        exit;
      End;
    If (recordType = 'WEAP') Then
      Begin
        RunWeaponRecord(e);
        exit;
      End;
    If (recordType = 'AMMO') Then
      Begin
        RunAmmoRecord(e);
        exit;
      End;
    If (recordType = 'ALCH') Then
      Begin
        RunAlchRecord(e);
        exit;
      End;
    If (recordType = 'MISC') Then
      Begin
        RunMiscRecord(e);
        exit;
      End;
    If (recordType = 'BOOK') Then
      Begin
        RunBookRecord(e);
        exit;
      End;
    If (recordType = 'INGR') Then
      Begin
        RunIngredientRecord(e);
        exit;
      End;
    If (recordType = 'KEYM') Then
      Begin
        RunKeyRecord(e);
        exit;
      End;
    If (recordType = 'SCRL') Then
      Begin
        RunScrollRecord(e);
        exit;
      End;
  End;

Function Finalize(): integer;
  Begin
    AddMessage('Writing to file...');
    If (heavyArmor.Count > 0) Then
      Begin
        WriteToFile(heavyArmor, 'tempArmor.json');
        DumpToLog(heavyArmor);
      End;
    If (lightArmor.Count >0) Then
      Begin
        WriteToFile(lightArmor, 'tempArmorL.json');
        DumpToLog(lightArmor);
      End;
    If (shields.Count > 0) Then
      Begin
        WriteToFile(shields, 'tempArmorS.json');
        DumpToLog(shields);
      End;
    If (oneHanded.Count > 0) Then
      Begin
        WriteToFile(oneHanded, 'tempWeapons.json');
        DumpToLog(oneHanded);
      End;
    If (twoHanded.Count > 0) Then
      Begin
        WriteToFile(twoHanded, 'tempWeapons2H.json');
        DumpToLog(twoHanded);
      End;
    If (bow.Count > 0) Then
      Begin
        WriteToFile(bow, 'tempWeaponsB.json');
        DumpToLog(bow);
      End;
    If (staff.Count > 0) Then
      Begin
        WriteToFile(staff, 'tempWeaponsS.json');
        DumpToLog(staff);
      End;
    If (jewelery.Count > 0) Then
      Begin
        WriteToFile(jewelery, 'tempValuablesJ.json');
        DumpToLog(jewelery);
      End;
    If (clothesBody.Count > 0) Then
      Begin
        WriteToFile(clothesBody, 'tempClothing.json');
        DumpToLog(clothesBody);
      End;
    If (clothesChildren.Count > 0) Then
      Begin
        WriteToFile(clothesChildren, 'tempClothingC.json');
        DumpToLog(clothesChildren);
      End;
    If (clothesHandFeet.Count > 0) Then
      Begin
        WriteToFile(clothesHandFeet, 'tempClothingG.json');
        DumpToLog(clothesHandFeet);
      End;
    If (potionsPoisons.Count > 0) Then
      Begin
        WriteToFile(potionsPoisons, 'tempPotionsPoi.json');
        DumpToLog(potionsPoisons);
      End;
    If (potionsBeneficial.Count > 0) Then
      Begin
        WriteToFile(potionsBeneficial, 'tempPotionsPot.json');
        DumpToLog(potionsBeneficial);
      End;
    If (foodItem.Count > 0) Then
      Begin
        WriteToFile(foodItem, 'tempFoodFD.json');
        DumpToLog(foodItem);
      End;
    If (foodIngredient.Count > 0) Then
      Begin
        WriteToFile(foodIngredient, 'tempFoodCI.json');
        DumpToLog(foodIngredient);
      End;
    If (ingredient.Count > 0) Then
      Begin
        WriteToFile(ingredient, 'tempAlchemy.json');
        DumpToLog(ingredient);
      End;
    If (spellTomes.Count > 0) Then
      Begin
        WriteToFile(spellTomes, 'tempBooksST.json');
        DumpToLog(spellTomes);
      End;
    If (books.Count > 0) Then
      Begin
        WriteToFile(books, 'tempBooksB.json');
        DumpToLog(books);
      End;
    If (scrolls.Count > 0) Then
      Begin
        WriteToFile(scrolls, 'tempBooksS.json');
        DumpToLog(scrolls);
      End;
    If (keys.Count > 0) Then
      Begin
        WriteToFile(keys, 'tempKeys.json');
        DumpToLog(keys);
      End;
    If (oreAndIngots.Count > 0) Then
      Begin
        WriteToFile(oreAndIngots, 'tempCraftingIO.json');
        DumpToLog(oreAndIngots);
      End;
    If (gems.Count > 0) Then
      Begin
        WriteToFile(gems, 'tempValuablesG.json');
        DumpToLog(gems);
      End;
    If (skinBoneLeather.Count > 0) Then
      Begin
        WriteToFile(skinBoneLeather, 'tempCraftingLSB.json');
        DumpToLog(skinBoneLeather);
      End;
    If (clutter.Count > 0) Then
      Begin
        WriteToFile(clutter, 'tempRandom.json');
        DumpToLog(clutter);
      End;
    If (treasures.Count > 0) Then
      Begin
        WriteToFile(treasures, 'tempXGold.json');
        DumpToLog(treasures);
      End;
    If (homeItems.Count > 0) Then
      Begin
        WriteToFile(homeItems, 'tempCraftingHR.json');
        DumpToLog(homeItems);
      End;
    AddMessage('Haha. Script go brrrrr');
    Result := 1;
  End;

End.
