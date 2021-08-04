package org.pmvp.sqldelight

import com.squareup.sqldelight.db.SqlDriver

/**
 * Creates unique for the platform SQLDriver
 */
interface SqlDriverFactory {
    fun createSqlDriver(
        schema: SqlDriver.Schema,
        filename: String
    ): SqlDriver
}
