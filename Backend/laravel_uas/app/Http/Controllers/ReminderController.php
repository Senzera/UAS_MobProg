<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Reminder;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;

class ReminderController extends Controller
{
    public function index()
    {
        $reminders = Reminder::where('user_id', Auth::id())->get();
        return response()->json($reminders);
    }

    public function store(Request $request)
    {
        Log::info('Store method called');
        $data = $request->all();
    
        $validator = Validator::make($data, [
            'description' => 'required|string|max:255',
            'time' => 'required|date_format:H:i',
        ]);
    
        if ($validator->fails()) {
            return response()->json(['error' => 'Invalid data format.'], 400);
        }
    
        // Simpan reminder untuk user yang sedang terautentikasi
        $reminder = Reminder::create([
            'user_id' => Auth::id(),
            'description' => $data['description'],
            'time' => $data['time'],
        ]);
    
        return response()->json($reminder, 201);
    }    
        
        
    
    public function show($id)
    {
        $reminder = Reminder::where('user_id', Auth::id())->findOrFail($id);
        return response()->json($reminder);
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'description' => 'required|string|max:255',
            'time' => 'required|date_format:H:i',
        ]);

        $reminder = Reminder::where('user_id', Auth::id())->findOrFail($id);
        $reminder->update([
            'description' => $request->description,
            'time' => $request->time,
        ]);

        return response()->json($reminder);
    }

    public function destroy($id)
    {
        $reminder = Reminder::where('user_id', Auth::id())->findOrFail($id);
        $reminder->delete();

        return response()->json(null, 204);
    }
}

