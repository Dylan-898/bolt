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
        Schema::create('solicitud_ambiente', function (Blueprint $table) {
            $table->integer('id_solicitud');
            $table->integer('id_ambiente')->index('fk_sa_ambiente');

            $table->primary(['id_solicitud', 'id_ambiente']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('solicitud_ambiente');
    }
};
