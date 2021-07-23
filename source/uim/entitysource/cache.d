module uim.entitysource.cache;

@safe:
import uim.entitysource;

class DEDBCacheDb : DEDBentitysource {
  this() { super(); }
  this(DEDBentitysource myStorage, DEDBentitysource cache) { super(); }

  mixin(SProperty!("DEDBentitysource", "storage"));
  mixin(SProperty!("DEDBentitysource", "cache"));
}
auto EDBCacheDb() { return new DEDBCacheDb; }