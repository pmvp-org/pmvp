package org.pmvp.ktor

import kotlinx.coroutines.flow.Flow

/**
 * Authentication Token mechanism used to enable [KtorStorage] implementations to include a token.
 */
interface AuthTokenProvider {
    fun token(): Flow<String>
}
