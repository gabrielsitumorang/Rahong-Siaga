package com.rahong.floodwarning.di

import android.content.Context
import com.rahong.floodwarning.data.remote.ApiService
import com.rahong.floodwarning.data.repository.FloodRepositoryImpl
import com.rahong.floodwarning.domain.repository.FloodRepository
import com.rahong.floodwarning.util.NotificationHelper
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.util.concurrent.TimeUnit
import javax.inject.Singleton

/**
 * Modul Hilt untuk dependency injection di seluruh aplikasi.
 *
 * Menyediakan instance Retrofit, ApiService, Repository, dan helper utilities.
 * Semua dependency disediakan sebagai Singleton untuk efisiensi memori.
 */
@Module
@InstallIn(SingletonComponent::class)
object AppModule {

    /** Base URL default untuk API backend. Ganti sesuai konfigurasi server. */
    private const val BASE_URL = "http://10.0.2.2:8000/"

    /**
     * Menyediakan [OkHttpClient] dengan logging interceptor dan timeout yang dikonfigurasi.
     *
     * @return Instance [OkHttpClient] yang sudah dikonfigurasi.
     */
    @Provides
    @Singleton
    fun provideOkHttpClient(): OkHttpClient {
        val loggingInterceptor = HttpLoggingInterceptor().apply {
            level = HttpLoggingInterceptor.Level.BODY
        }
        return OkHttpClient.Builder()
            .addInterceptor(loggingInterceptor)
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .writeTimeout(30, TimeUnit.SECONDS)
            .build()
    }

    /**
     * Menyediakan instance [Retrofit] untuk komunikasi dengan backend API.
     *
     * @param okHttpClient Client HTTP yang akan digunakan oleh Retrofit.
     * @return Instance [Retrofit] yang sudah dikonfigurasi.
     */
    @Provides
    @Singleton
    fun provideRetrofit(okHttpClient: OkHttpClient): Retrofit {
        return Retrofit.Builder()
            .baseUrl(BASE_URL)
            .client(okHttpClient)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
    }

    /**
     * Menyediakan implementasi [ApiService] dari Retrofit.
     *
     * @param retrofit Instance Retrofit untuk membuat service.
     * @return Implementasi [ApiService].
     */
    @Provides
    @Singleton
    fun provideApiService(retrofit: Retrofit): ApiService {
        return retrofit.create(ApiService::class.java)
    }

    /**
     * Menyediakan implementasi [FloodRepository].
     *
     * @param apiService Service API yang digunakan oleh repository.
     * @return Implementasi [FloodRepository].
     */
    @Provides
    @Singleton
    fun provideFloodRepository(apiService: ApiService): FloodRepository {
        return FloodRepositoryImpl(apiService)
    }

    /**
     * Menyediakan [NotificationHelper] untuk mengelola notifikasi.
     *
     * @param context Application context.
     * @return Instance [NotificationHelper].
     */
    @Provides
    @Singleton
    fun provideNotificationHelper(@ApplicationContext context: Context): NotificationHelper {
        return NotificationHelper(context)
    }
}
