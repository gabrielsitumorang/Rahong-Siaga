package com.rahong.floodwarning.domain.model

/**
 * Sealed class generik untuk membungkus hasil operasi data.
 *
 * Digunakan sebagai wrapper di seluruh aplikasi untuk menangani
 * tiga state utama: Loading, Success, dan Error.
 *
 * @param T Tipe data yang dibungkus.
 * @property data Data hasil operasi. Null saat loading atau error tanpa cache.
 * @property message Pesan error. Null saat loading atau success.
 */
sealed class Resource<T>(
    val data: T? = null,
    val message: String? = null
) {
    /**
     * State berhasil dengan data yang valid.
     *
     * @param data Data hasil operasi yang berhasil.
     */
    class Success<T>(data: T) : Resource<T>(data)

    /**
     * State error dengan pesan kesalahan.
     *
     * @param message Pesan error yang menjelaskan kegagalan.
     * @param data Data cache yang mungkin masih tersedia.
     */
    class Error<T>(message: String, data: T? = null) : Resource<T>(data, message)

    /**
     * State loading saat operasi sedang berlangsung.
     *
     * @param data Data cache yang mungkin masih tersedia saat loading.
     */
    class Loading<T>(data: T? = null) : Resource<T>(data)
}
