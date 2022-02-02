module uim.entitysource.mongo;

@safe:
import uim.entitysource;

class DEDBMongoDb : DESCEntitySource {
this() { super(); this.separator("."); }
  this(string newPath) { this().path(newPath); }
  
  mixin(SProperty!("string", "path"));
  
  private MongoClient _client;

  override DEDBMongoDb connect() { 
    _client = connectMongoDB(path);
    return this;
  }

  override DEDBMongoDb cleanupConnections() { // cleanUp connections
    _client.cleanupConnections();
    return this;
  }
  // #region read
  // Searching in store
  alias findMany = DESCEntitySource.findMany;
  override Json[] findMany(string collection, bool allVersions = false) {
    Json[] jsons;
    writeln("Looking in "~collection);
    foreach(bson; _client.getCollection(collection).find()) { 
      auto json = bson.toJson; 
      json["pool"] = collection;
      jsons ~= json;
    }
    if (allVersions) return jsons;

    Json[][string] aggs;
    foreach(json; jsons) {
      auto id = json["id"].get!string;
      if (id !in aggs) aggs[id] = [json];
      else aggs[id] ~= [json];
    }
    return aggs.byKey().map!(a => uim.entities.repositories.lastVersion(aggs[a])).array; }
  unittest {}

  override Json[] findMany(string collection, UUID id, bool allVersions = false) {
    // debug writeln("In findMany(", collection, ",", id, ",", allVersions, ")");

    Json jsnSelect = Json.emptyObject;
    jsnSelect["id"] = id.toString;

    return findMany(collection, jsnSelect, allVersions); }
  unittest {}

  override Json[] findMany(string collection, STRINGAA select, bool allVersions = false) {
    // debug writeln("In findMany(", collection, ",", allVersions, ")");

    Json selector = select.serializeToJson;
    return findMany(collection, selector); }

  override Json[] findMany(string collection, Json select, bool allVersions = false) {
    debug writeln("DEDBMongoDb:findMany(", collection, ",", allVersions, ")");

    if (allVersions) return _client.getCollection(collection).find(select).map!(a => a.toJson).array; 
      return null;
/* 
    auto entityIds = dirNames(pathToCollection, true);    
    Json[] results;
    foreach(pathToId; entityIds) {
      auto allEntityVersions = loadJsonsFromDirectory(pathToId);
      if (allVersions) results ~= allEntityVersions;
      else results ~= uim.entities.repositories.lastVersion(allEntityVersions); }

    return results.filter!(a => checkVersion(a, select)).array; }

  alias findOne = DESCEntitySource.findOne;
  override Json findOne(string collection, UUID id, bool allVersions = false) {
    // debug writeln("In findOne(", collection, ",", id, ",", allVersions, ")");
    auto jsons = findMany(collection, id, allVersions);
    return jsons.length > 0 ? jsons[0] : Json(null); }
  unittest {
    writeln((StyledString("Test Json findOne(string collection, UUID id, bool allVersions = false)").setForeground(AnsiColor.black).setBackground(AnsiColor.white)));
    auto rep = EDBMongoDb("./tests");
    auto json = rep.findOne("entities", UUID("0a9f35a0-be1f-4f3f-9d03-97bfba36774d"));
    assert(json != Json(null), "Json not found"); */
  }    

  alias findOne = DESCEntitySource.findOne;
  override Json findOne(string collection, UUID id, size_t versionNumber) {
    // debug writeln("In findOne(", collection, ",", id, ",", versionNumber, ")");
    return Json(null); }
  unittest {
/*     auto rep = EDBMongoDb("./tests");
    auto json = rep.findOne("entities", UUID("0a9f35a0-be1f-4f3f-9d03-97bfba36774d"), 1);
    assert(json != Json(null)); */
  }    

  override Json findOne(string collection, STRINGAA select, bool allVersions = false) {
    // debug writeln("In findOne(", collection, ",", select, ",", allVersions, ")");
    auto jsons = findMany(collection, select, allVersions);
    return jsons.length > 0 ? jsons[0] : Json(null); }
  unittest {
/*     auto rep = EDBMongoDb("./tests");
    auto select = [
      "id": "0a9f35a0-be1f-4f3f-9d03-97bfba36774d", 
      "versionNumber": "1"];
    auto json = rep.findOne("entities", select);
    assert(json != Json(null), "json not found"); */
  }    

  override Json findOne(string collection, Json select, bool allVersions = false) {
    // debug writeln("In findOne(", collection, ",", select, ",", allVersions, ")");
    auto jsons = findMany(collection, select, allVersions);
    return jsons.length > 0 ? jsons[0] : Json(null); }
  unittest {
    // debug writeln((StyledString("Test Json findOne(string collection, Json select, bool allVersions = false)").setForeground(AnsiColor.black).setBackground(AnsiColor.white)));
/*     auto rep = EDBMongoDb("./tests");
    auto json = Json.emptyObject;
    json["id"] = "0a9f35a0-be1f-4f3f-9d03-97bfba36774d";
    json["versionNumber"] = 1;
    json = rep.findOne("entities", json);
    assert(json != Json(null)); */
  }    
  // #endregion

// #region create
  alias insertOne = DESCEntitySource.insertOne;
  override Json insertOne(string collection, Json newData) {
    _client.getCollection(collection).insert(newData);
    return findOne(collection, newData);
  }
  unittest {
    // debug writeln((StyledString("Test Json insertOne(string collection, Json newData)").setForeground(AnsiColor.black).setBackground(AnsiColor.white)));

    auto rep = EDBMongoDb("./tests");
    const json = rep.insertOne("entities", OOPEntity.toJson);
    assert(json != Json(null));
  }
// #endregion create

// #region UpdateMany
  alias updateOne = DESCEntitySource.updateOne;
  override bool updateOne(string collection, Json select, Json updateData) {
    updateData.remove("_id");
    _client.getCollection(collection).update(select, updateData);
    return findOne(collection, select) != Json(null); }
// #endregion update

// #region removeOne  
  alias removeOne = DESCEntitySource.removeOne;
  override bool removeOne(string collection, UUID id, bool allVersions = false) {
    Json select = findOne(collection, id, allVersions);
    _client.getCollection(collection).remove(select);
    return false; } 
  unittest {
    // debug writeln((StyledString("Test bool removeOne(string collection, UUID id, bool allVersions = false)").setForeground(AnsiColor.black).setBackground(AnsiColor.white)));

    auto rep = EDBMongoDb("./tests");
    auto entity = OOPEntity;
    auto json = rep.insertOne("entities", entity);
    assert(rep.removeOne("entities", json));    

    entity = OOPEntity;
    json = rep.insertOne("entities", entity);
    assert(rep.removeOne("entities", json));    
  }

  override bool removeOne(string collection, UUID id, size_t versionNumber) {
    auto pathToCollection = path~"/"~collection;
    if (!pathToCollection.exists) return false;

    auto json = findOne(collection, id, versionNumber); 
    if (json != Json(null)) {
      auto jPath = filePath(pathToCollection, json);
      jPath.remove;
      return !jPath.exists; }
    return false; }
  unittest {
    auto rep = EDBMongoDb("./tests");
    assert(test_removeOne_id_versionNumber(rep));
  }

  override bool removeOne(string collection, Json select, bool allVersions = false) {    
    _client.getCollection(collection).remove(select);
    return findOne(collection, select, allVersions) == Json(null); }
  unittest {
    auto rep = EDBMongoDb("./tests");
    assert(test_removeOne_collection_jsonselect(rep));    
    assert(test_removeOne_collection_jsonselect_allVersions(rep));
  }
}
auto EDBMongoDb() { return new DEDBMongoDb; }
auto EDBMongoDb(string path) { return new DEDBMongoDb(path); }