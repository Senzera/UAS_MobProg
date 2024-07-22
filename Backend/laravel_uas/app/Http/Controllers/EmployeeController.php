<?php

namespace App\Http\Controllers;

use App\Models\Employee;
use Illuminate\Http\Request;

class EmployeeController extends Controller
{
    /**
     * Get the profile of the authenticated user.
     */
    public function getProfile(Request $request)
    {
        // Pastikan pengguna terautentikasi
        if (!$request->user()) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        // Dapatkan ID pengguna yang terautentikasi
        $userId = $request->user()->id;

        // Cari profil karyawan berdasarkan user_id
        $employee = Employee::where('user_id', $userId)->first();

        if ($employee) {
            return response()->json($employee, 200);
        } else {
            return response()->json(['message' => 'Profile not found'], 404);
        }
    }

    /**
     * Update or create the profile of the authenticated user.
     */
    public function updateProfile(Request $request)
    {
        // Pastikan pengguna terautentikasi
        if (!$request->user()) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        // Dapatkan ID pengguna yang terautentikasi
        $userId = $request->user()->id;

        // Validasi data input
        $validatedData = $request->validate([
            'Nama' => 'required|string|max:255',
            'Alamat' => 'required|string|max:255',
            'Jenis_Kelamin' => 'required|string|max:255',
        ]);

        // Update atau buat entitas Employee berdasarkan user_id
        $employee = Employee::updateOrCreate(
            ['user_id' => $userId],
            [
                'Nama' => $validatedData['Nama'],
                'Alamat' => $validatedData['Alamat'],
                'Jenis_Kelamin' => $validatedData['Jenis_Kelamin'],
            ]
        );

        // Berikan respons JSON
        return response()->json($employee, 200);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        // Pastikan pengguna terautentikasi
        if (!$request->user()) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        // Validasi data input
        $request->validate([
            'Nama' => 'required|string|max:255',
            'Alamat' => 'required|string|max:255',
            'Jenis_Kelamin' => 'required|in:Laki-laki,Perempuan',
        ]);

        // Dapatkan ID pengguna yang terautentikasi
        $userId = $request->user()->id;

        // Buat entitas Employee baru
        $employee = Employee::create([
            'user_id' => $userId,
            'Nama' => $request->input('Nama'),
            'Alamat' => $request->input('Alamat'),
            'Jenis_Kelamin' => $request->input('Jenis_Kelamin'),
        ]);

        // Berikan respons JSON dengan pesan sukses dan data karyawan yang dibuat
        return response()->json(['message' => 'Employee created successfully', 'data' => $employee], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show($id)
    {
        // Cari karyawan berdasarkan ID
        $employee = Employee::find($id);

        if (!$employee) {
            return response()->json(['message' => 'Employee not found'], 404);
        }

        // Berikan respons JSON dengan data karyawan yang ditemukan
        return response()->json($employee);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id)
    {
        // Validasi data input
        $request->validate([
            'Nama' => 'sometimes|required|string|max:255',
            'Alamat' => 'sometimes|required|string|max:255',
            'Jenis_Kelamin' => 'sometimes|required|in:Laki-laki,Perempuan',
        ]);

        // Cari karyawan berdasarkan ID
        $employee = Employee::find($id);

        if (!$employee) {
            return response()->json(['message' => 'Employee not found'], 404);
        }

        // Update data karyawan
        $employee->update($request->all());

        // Berikan respons JSON dengan pesan sukses dan data karyawan yang diperbarui
        return response()->json(['message' => 'Employee updated successfully', 'data' => $employee]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id)
    {
        // Cari karyawan berdasarkan ID
        $employee = Employee::find($id);

        if (!$employee) {
            return response()->json(['message' => 'Employee not found'], 404);
        }

        // Hapus karyawan
        $employee->delete();

        // Berikan respons JSON dengan pesan sukses
        return response()->json(['message' => 'Employee deleted successfully']);
    }
}
