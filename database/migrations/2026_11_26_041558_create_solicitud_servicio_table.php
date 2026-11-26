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
        Schema::create('solicitud_servicio', function (Blueprint $table) {
            $table->integer('id_solicitud');
            $table->integer('id_servicio')->index('fk_ss_servicio');

            $table->primary(['id_solicitud', 'id_servicio']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('solicitud_servicio');
    }
};
