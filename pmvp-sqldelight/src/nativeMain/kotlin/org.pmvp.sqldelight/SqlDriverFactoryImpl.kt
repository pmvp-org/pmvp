package org.pmvp.sqldelight

import com.squareup.sqldelight.db.SqlDriver
import com.squareup.sqldelight.drivers.native.NativeSqliteDriver
import org.pmvp.sqldelight.SqlDriverFactory

class SqlDriverFactoryImpl: SqlDriverFactory {
    override fun createSqlDriver(
        schema: SqlDriver.Schema,
        filename: String
    ): SqlDriver = NativeSqliteDriver(
        schema,
        filename
    )
}
