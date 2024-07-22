<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Employee; // Adjust this based on your Employee model

class ProfileController extends Controller
{
    public function saveProfile(Request $request)
    {
        $validatedData = $request->validate([
            'username' => 'required|string',
            'address' => 'required|string',
            'birthPlace' => 'required|string',
            'gender' => 'required|string',
        ]);

        $employee = new Employee();
        $employee->Nama = $validatedData['username'];
        $employee->Alamat = $validatedData['address'];
        $employee->Tempat_Lahir = $validatedData['birthPlace'];
        $employee->Jenis_Kelamin = $validatedData['gender'];
        $employee->save();

        return response()->json(['message' => 'Data profil disimpan'], 200);
    }
}
