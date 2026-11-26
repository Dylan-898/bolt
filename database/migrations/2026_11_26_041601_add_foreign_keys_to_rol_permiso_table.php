<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('rol_permiso', function (Blueprint $table) {
            $table->foreign(['id_permisos'], 'fk_rp_permisos')->references(['id_permisos'])->on('permisos')->onUpdate('cascade')->onDelete('cascade');
            $table->foreign(['id_rol'], 'fk_rp_rol')->references(['id_rol'])->on('rol')->onUpdate('cascade')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('rol_permiso', function (Blueprint $table) {
            $table->dropForeign('fk_rp_permisos');
            $table->dropForeign('fk_rp_rol');
        });
    }
};
