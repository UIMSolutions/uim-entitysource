module uim.entitysource.cache;

@safe:
import uim.entitysource;

class DEDBCacheDb : DESCEntitySource {
  this() { super(); }
  this(DESCEntitySource myStorage, DESCEntitySource cache) { super(); }

  mixin(SProperty!("DESCEntitySource", "storage"));
  mixin(SProperty!("DESCEntitySource", "cache"));
}
auto EDBCacheDb() { return new DEDBCacheDb; }