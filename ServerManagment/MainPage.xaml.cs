using System.Net.Http;
using System.Net.Http.Json;
using System.Text.Json;
using Microsoft.Maui.Controls;
using Microsoft.Maui.Storage;

namespace ServerManagment;

public partial class MainPage : ContentPage
{
    private readonly HttpClient _httpClient;
    private const string ServerUrl = "http://127.0.0.1:5000";
    private const string ApiKey = "APIKEY123";
    private string logText = ""; // Przechowujemy logi jako ciągły tekst

    public MainPage()
    {
        InitializeComponent();
        _httpClient = new HttpClient();
        _httpClient.DefaultRequestHeaders.Add("X-Api-Key", ApiKey);
        GetServerLogs();
        OnRefreshFilesClicked(null, null);
    }

    // Metoda do aktualizacji listy plików
    private async void OnRefreshFilesClicked(object sender, EventArgs e)
    {
        try
        {
            StatusLabel.Text = "Refreshing...";
            var response = await _httpClient.GetFromJsonAsync<FileListResponse>($"{ServerUrl}/list");
            FilesList.ItemsSource = response?.Files.Select(f => new FileItem { Name = f });
            StatusLabel.Text = "Files refreshed";
            AddToLog("Refreshed file list");
        }
        catch (Exception ex)
        {
            StatusLabel.Text = $"Error: {ex.Message}";
            AddToLog($"Error refreshing files: {ex.Message}");
        }
    }

    // Metoda do dodawania wpisów do logów
    private void AddToLog(string message)
    {
        logText += $"{DateTime.Now:HH:mm:ss} - {message}\n";
        ConsoleLabel.Text = logText;
        Server_Logs.ScrollToAsync(ConsoleLabel, ScrollToPosition.End, false); // Auto-scroll do końca
    }

    private async void OnUploadFileClicked(object sender, EventArgs e)
    {
        try
        {
            var result = await FilePicker.PickAsync();
            if (result != null)
            {
                var stream = await result.OpenReadAsync();
                var content = new MultipartFormDataContent();
                content.Add(new StreamContent(stream), "file", result.FileName);
                var response = await _httpClient.PostAsync($"{ServerUrl}/upload", content);
                response.EnsureSuccessStatusCode();
                StatusLabel.Text = $"Uploaded {result.FileName}";
                AddToLog($"File uploaded: {result.FileName}");
                await Task.Delay(100); // Krótkie opóźnienie dla stabilności
                OnRefreshFilesClicked(null, null); // Automatyczne odświeżenie listy
            }
        }
        catch (Exception ex)
        {
            StatusLabel.Text = $"Error: {ex.Message}";
            AddToLog($"Error uploading file: {ex.Message}");
        }
    }

    private async void OnDownloadFileClicked(object sender, EventArgs e)
    {
        var button = sender as Button;
        var filename = button?.CommandParameter as string;
        try
        {
            var response = await _httpClient.GetAsync($"{ServerUrl}/download/{filename}");
            response.EnsureSuccessStatusCode();
            var stream = await response.Content.ReadAsStreamAsync();
            var path = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), filename);
            await using var fileStream = File.Create(path);
            await stream.CopyToAsync(fileStream);
            StatusLabel.Text = $"Downloaded to {path}";
            AddToLog($"File downloaded: {filename} to {path}");
            await Task.Delay(100);
            OnRefreshFilesClicked(null, null); // Automatyczne odświeżenie listy
        }
        catch (Exception ex)
        {
            StatusLabel.Text = $"Error: {ex.Message}";
            AddToLog($"Error downloading file: {ex.Message}");
        }
    }

    private async void GetServerLogs()
    {
        try
        {
            var response = await _httpClient.GetFromJsonAsync<GetLogsResponse>($"{ServerUrl}/logs");
            AddToLog("Server logs retrieved");
            ConsoleLabel.Text = response?.Logs ?? "No logs available";
            await Server_Logs.ScrollToAsync(ConsoleLabel, ScrollToPosition.End, false);
        }
        catch (Exception ex)
        {
            StatusLabel.Text = $"Error: {ex.Message}";
            AddToLog($"Error refreshing logs: {ex.Message}");
        }
    }

    private async void OnDeleteFileClicked(object sender, EventArgs e)
    {
        var button = sender as Button;
        var filename = button?.CommandParameter as string;
        try
        {
            var response = await _httpClient.DeleteAsync($"{ServerUrl}/delete/{filename}");
            response.EnsureSuccessStatusCode();
            StatusLabel.Text = $"Deleted {filename}";
            AddToLog($"File deleted: {filename}");
            await Task.Delay(100);
            OnRefreshFilesClicked(null, null); // Automatyczne odświeżenie listy
        }
        catch (Exception ex)
        {
            StatusLabel.Text = $"Error: {ex.Message}";
            AddToLog($"Error deleting file: {ex.Message}");
        }
    }

    private async void OnRenameFileClicked(object sender, EventArgs e)
    {
        var button = sender as Button;
        var filename = button?.CommandParameter as string;
        var newName = await DisplayPromptAsync("Rename File", "Enter new name:", initialValue: filename);
        if (!string.IsNullOrEmpty(newName))
        {
            try
            {
                var content = new StringContent(JsonSerializer.Serialize(new { new_name = newName }), System.Text.Encoding.UTF8, "application/json");
                var response = await _httpClient.PostAsync($"{ServerUrl}/move/{filename}", content);
                response.EnsureSuccessStatusCode();
                StatusLabel.Text = $"Renamed to {newName}";
                AddToLog($"File renamed from {filename} to {newName}");
                await Task.Delay(100);
                OnRefreshFilesClicked(null, null); // Automatyczne odświeżenie listy
            }
            catch (Exception ex)
            {
                StatusLabel.Text = $"Error: {ex.Message}";
                AddToLog($"Error renaming file: {ex.Message}");
            }
        }
    }

    private async void OnStartServerClicked(object sender, EventArgs e)
    {
        StatusLabel.Text = "Starting server requires manual action.";
        AddToLog("Server start requested (manual action required)");
    }

    private async void OnStopServerClicked(object sender, EventArgs e)
    {
        StatusLabel.Text = "Stopping server requires manual action.";
        AddToLog("Server stop requested (manual action required)");
    }

    // Metody do zmiennej serwera (z poprzedniego przykładu)
    private async void OnUpdateVariableClicked(object sender, EventArgs e)
    {
        try
        {
            var newValue = await DisplayPromptAsync("Update Server Variable", "Enter new value:", "OK", "Cancel", "New Value");
            if (!string.IsNullOrEmpty(newValue))
            {
                var content = new StringContent(JsonSerializer.Serialize(new { new_value = newValue }), System.Text.Encoding.UTF8, "application/json");
                var response = await _httpClient.PostAsync($"{ServerUrl}/update_variable", content);
                response.EnsureSuccessStatusCode();
                var responseData = await response.Content.ReadFromJsonAsync<UpdateVariableResponse>();
                StatusLabel.Text = responseData?.Message ?? "Variable updated";
                AddToLog($"Updated server variable to: {newValue}");
                await Task.Delay(100);
                OnRefreshFilesClicked(null, null); // Automatyczne odświeżenie listy
            }
        }
        catch (Exception ex)
        {
            StatusLabel.Text = $"Error: {ex.Message}";
            AddToLog($"Error updating variable: {ex.Message}");
        }
    }

    private async void OnGetVariableClicked(object sender, EventArgs e)
    {
        try
        {
            var response = await _httpClient.GetFromJsonAsync<GetVariableResponse>($"{ServerUrl}/get_variable");
            StatusLabel.Text = $"Server variable: {response?.ServerVariable}";
            AddToLog($"Retrieved server variable: {response?.ServerVariable}");
        }
        catch (Exception ex)
        {
            StatusLabel.Text = $"Error: {ex.Message}";
            AddToLog($"Error getting variable: {ex.Message}");
        }
    }
}

public class UpdateVariableResponse
{
    public string Message { get; set; }
}

public class GetVariableResponse
{
    public string ServerVariable { get; set; }
}

public class FileListResponse
{
    public List<string> Files { get; set; }
}

public class FileItem
{
    public string Name { get; set; }
}

public class GetLogsResponse
{
    public string Logs { get; set; }
}