from django.shortcuts import render, redirect
from .models import AnimalReport

def home(request):
    if request.method == "POST":
        name = request.POST['name']
        contact = request.POST['contact']
        location = request.POST['location']
        description = request.POST['description']
        
        AnimalReport.objects.create(
            name=name,
            contact=contact,
            location=location,
            description=description
        )

        return redirect('home')

    reports = AnimalReport.objects.all().order_by('-reported_at')
    return render(request, 'myapp.html', {'reports': reports})
